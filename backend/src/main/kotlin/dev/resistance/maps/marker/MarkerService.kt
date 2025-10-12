package dev.resistance.maps.marker

import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class MarkerService(private val repo: MarkerRepository) {

    fun publicMarkers(): List<Marker> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun myMarkers(auth: Authentication): List<Marker> = repo.findAllByCreatedBy(auth.name)

    fun createMarker(request: MarkerCreateRequest, auth: Authentication): Marker {
        val marker = Marker(
            title = request.title,
            description = request.description,
            lat = request.lat,
            lng = request.lng,
            visibility = request.visibility ?: Visibility.PUBLIC,
            createdBy = auth.name,
            tags = request.tags?.toSet() ?: emptySet()
        )
        return repo.save(marker)
    }
}

data class MarkerCreateRequest(
    val title: String,
    val description: String? = null,
    val lat: Double,
    val lng: Double,
    val tags: List<String>? = null,
    val visibility: Visibility? = null,
)
