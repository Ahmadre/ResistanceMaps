package dev.resistance.maps.share

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("shares")
data class Share(
    @Id val id: String? = null,
    val resourceType: ResourceType,
    @Indexed val resourceId: String,
    @Indexed val sharedWithUserId: String? = null,
    @Indexed val sharedWithGroupId: String? = null,
    @Indexed val expiresAt: Instant? = null,
    val createdBy: String,
    val createdAt: Instant = Instant.now(),
)
