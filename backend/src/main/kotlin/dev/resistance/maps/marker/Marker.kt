package dev.resistance.maps.marker

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document("markers")
data class Marker(
    @Id val id: String? = null,
    val title: String,
    val description: String? = null,
    val lat: Double,
    val lng: Double,
    val visibility: Visibility = Visibility.PUBLIC,
    val createdBy: String,
    val tags: Set<String> = emptySet()
)
