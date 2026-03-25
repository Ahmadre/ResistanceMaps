package dev.resistance.maps.group

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("groups")
data class Group(
    @Id val id: String? = null,
    @Indexed val name: String,
    val description: String? = null,
    val createdBy: String,
    val createdAt: Instant = Instant.now(),
)
