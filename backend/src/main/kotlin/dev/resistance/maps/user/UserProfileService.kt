package dev.resistance.maps.user

import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class UserProfileService(private val repo: UserProfileRepository) {

    fun getOrCreateProfile(auth: Authentication): UserProfile {
        val userId = auth.name
        return repo.findByUserId(userId) ?: run {
            val jwt = (auth.principal as? Jwt)
            val username = jwt?.getClaimAsString("preferred_username") ?: userId
            val email = jwt?.getClaimAsString("email") ?: "$userId@unknown"
            val displayName = jwt?.getClaimAsString("name")
            repo.save(UserProfile(userId = userId, username = username, email = email, displayName = displayName))
        }
    }

    fun getByUserId(userId: String): UserProfile? = repo.findByUserId(userId)

    fun getByUsername(username: String): UserProfile? = repo.findByUsername(username)

    fun getByEmail(email: String): UserProfile? = repo.findByEmail(email)

    fun getByUserIds(userIds: Collection<String>): List<UserProfile> = repo.findByUserIdIn(userIds)

    fun updateProfile(auth: Authentication, isPublic: Boolean?, displayName: String?): UserProfile {
        val profile = getOrCreateProfile(auth)
        val updated = profile.copy(
            isPublic = isPublic ?: profile.isPublic,
            displayName = displayName ?: profile.displayName,
        )
        return repo.save(updated)
    }

    fun searchUsers(query: String, auth: Authentication, visibleUserIds: Set<String>?, page: Int, size: Int): Page<UserProfile> {
        val pageable = PageRequest.of(page, size)
        return if (visibleUserIds != null) {
            repo.findByUserIdInAndUsernameContainingIgnoreCase(visibleUserIds, query, pageable)
        } else {
            repo.findByIsPublicTrueAndUsernameContainingIgnoreCase(query, pageable)
        }
    }
}
