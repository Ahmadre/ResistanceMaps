package dev.resistance.maps.marker

import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class MarkerService(private val repo: MarkerRepository) {

    fun publicMarkers(): List<Marker> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun myMarkers(auth: Authentication): List<Marker> = repo.findAllByCreatedBy(auth.name)

    fun publicMarkersInViewport(south: Double, west: Double, north: Double, east: Double, page: Int, size: Int): Page<Marker> {
        val p = PageRequest.of(page, size)
        val latStart = minOf(south, north)
        val latEnd = maxOf(south, north)
        val lngStart = minOf(west, east)
        val lngEnd = maxOf(west, east)
        return repo.findAllByVisibilityAndLatBetweenAndLngBetween(Visibility.PUBLIC, latStart, latEnd, lngStart, lngEnd, p)
    }

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

    fun updateMarker(id: String, request: MarkerUpdateRequest, auth: Authentication): Marker {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        // Only owner or admins can update
        if (existing.createdBy != auth.name && !hasAdminRole(auth)) {
            throw IllegalAccessException("Not allowed to update this marker")
        }
        val updated = existing.copy(
            title = request.title ?: existing.title,
            description = request.description ?: existing.description,
            lat = request.lat ?: existing.lat,
            lng = request.lng ?: existing.lng,
            visibility = request.visibility ?: existing.visibility,
            tags = request.tags?.toSet() ?: existing.tags,
        )
        return repo.save(updated)
    }

    fun deleteMarker(id: String, auth: Authentication) {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        if (existing.createdBy != auth.name && !hasAdminRole(auth)) {
            throw IllegalAccessException("Not allowed to delete this marker")
        }
        repo.deleteById(id)
    }

    private fun hasAdminRole(auth: Authentication): Boolean {
        val roles = auth.authorities.map { it.authority }
        return roles.any { it == "ROLE_ADMIN" || it == "ROLE_SUPERADMIN" }
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

data class MarkerUpdateRequest(
    val title: String? = null,
    val description: String? = null,
    val lat: Double? = null,
    val lng: Double? = null,
    val tags: List<String>? = null,
    val visibility: Visibility? = null,
)
