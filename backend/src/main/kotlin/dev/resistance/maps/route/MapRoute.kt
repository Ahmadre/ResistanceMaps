package dev.resistance.maps.route

import dev.resistance.maps.marker.Visibility
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("routes")
data class MapRoute(
    @Id val id: String? = null,
    val title: String,
    val description: String? = null,
    val waypoints: List<GeoPoint> = emptyList(),
    @Indexed val visibility: Visibility = Visibility.PUBLIC,
    @Indexed val createdBy: String,
    @Indexed val groupId: String? = null,
    val tags: Set<String> = emptySet(),
    val coverImageId: String? = null,
    val imageIds: List<String> = emptyList(),
    val documentIds: List<String> = emptyList(),
    val webLink: String? = null,
    @Indexed val expiresAt: Instant? = null,
    val passwordHash: String? = null,
    val shareToken: String? = null,
    val publicShareToken: String? = null,
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
)
