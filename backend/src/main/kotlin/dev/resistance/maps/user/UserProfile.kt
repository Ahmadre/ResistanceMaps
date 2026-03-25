package dev.resistance.maps.user

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("user_profiles")
data class UserProfile(
    @Id val id: String? = null,
    @Indexed(unique = true) val userId: String,
    @Indexed(unique = true) val username: String,
    @Indexed(unique = true) val email: String,
    val displayName: String? = null,
    val isPublic: Boolean = true,
    val createdAt: Instant = Instant.now(),
)
