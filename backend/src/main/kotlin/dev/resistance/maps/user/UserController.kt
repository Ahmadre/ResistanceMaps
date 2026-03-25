package dev.resistance.maps.user

import org.springframework.data.domain.Page
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/users")
class UserController(
    private val service: UserProfileService,
    private val groupMemberRepo: dev.resistance.maps.group.GroupMemberRepository,
    private val connectionRepo: dev.resistance.maps.connection.ConnectionRepository,
) {

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun me(auth: Authentication): UserProfile = service.getOrCreateProfile(auth)

    @PatchMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun updateMe(auth: Authentication, @RequestBody req: UpdateProfileRequest): UserProfile =
        service.updateProfile(auth, req.isPublic, req.displayName)

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    fun search(
        auth: Authentication,
        @RequestParam q: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
    ): Page<UserProfile> {
        val userId = auth.name
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }

        val visibleUserIds: Set<String>? = if (isSuperAdmin) {
            null // superadmin sees all
        } else {
            val groupIds = groupMemberRepo.findAllByUserId(userId).map { it.groupId }
            val groupMembers = if (groupIds.isNotEmpty()) groupMemberRepo.findAllByGroupIdIn(groupIds).map { it.userId }.toSet() else emptySet()
            val connections = connectionRepo.findAllAcceptedForUser(userId).map { if (it.requesterId == userId) it.targetId else it.requesterId }.toSet()
            groupMembers + connections + userId
        }

        return service.searchUsers(q, auth, visibleUserIds, page, size)
    }

    @GetMapping("/{userId}")
    @PreAuthorize("isAuthenticated()")
    fun getUser(@PathVariable userId: String, auth: Authentication): ResponseEntity<UserProfile> {
        val profile = service.getByUserId(userId) ?: return ResponseEntity.notFound().build()
        val requesterId = auth.name
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin || profile.isPublic || profile.userId == requesterId) {
            return ResponseEntity.ok(profile)
        }
        // Check if in same group or connected
        val sharedGroups = groupMemberRepo.findAllByUserId(requesterId).map { it.groupId }
        val targetGroups = groupMemberRepo.findAllByUserId(userId).map { it.groupId }
        if (sharedGroups.intersect(targetGroups.toSet()).isNotEmpty()) {
            return ResponseEntity.ok(profile)
        }
        val connected = connectionRepo.findAccepted(requesterId, userId) != null
        if (connected) return ResponseEntity.ok(profile)
        return ResponseEntity.status(403).build()
    }
}

data class UpdateProfileRequest(
    val isPublic: Boolean? = null,
    val displayName: String? = null,
)
