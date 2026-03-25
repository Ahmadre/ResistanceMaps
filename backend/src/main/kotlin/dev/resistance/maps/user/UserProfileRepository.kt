package dev.resistance.maps.user

import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.mongodb.repository.MongoRepository

interface UserProfileRepository : MongoRepository<UserProfile, String> {
    fun findByUserId(userId: String): UserProfile?
    fun findByUsername(username: String): UserProfile?
    fun findByEmail(email: String): UserProfile?
    fun findByUserIdIn(userIds: Collection<String>): List<UserProfile>
    fun findByIsPublicTrueAndUsernameContainingIgnoreCase(username: String, pageable: Pageable): Page<UserProfile>
    fun findByUserIdInAndUsernameContainingIgnoreCase(userIds: Collection<String>, username: String, pageable: Pageable): Page<UserProfile>
}
