package dev.resistance.maps.maplist

import dev.resistance.maps.marker.Visibility
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("map_lists")
data class MapList(
    @Id val id: String? = null,
    val title: String,
    val description: String? = null,
    @Indexed val visibility: Visibility = Visibility.PUBLIC,
    @Indexed val createdBy: String,
    val markerIds: List<String> = emptyList(),
    val routeIds: List<String> = emptyList(),
    @Indexed val expiresAt: Instant? = null,
    val passwordHash: String? = null,
    val shareToken: String? = null,
    val publicShareToken: String? = null,
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
)
