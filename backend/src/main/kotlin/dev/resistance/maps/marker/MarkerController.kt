package dev.resistance.maps.marker

import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import dev.resistance.maps.marker.MarkerUpdateRequest

@RestController
@RequestMapping("/api/markers")
class MarkerController(private val service: MarkerService) {

    @GetMapping("/public")
    fun listPublic(): List<Marker> = service.publicMarkers()

    @GetMapping("/public/viewport")
    fun listPublicViewport(
        @RequestParam south: Double,
        @RequestParam west: Double,
        @RequestParam north: Double,
        @RequestParam east: Double,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "100") size: Int,
    ) = service.publicMarkersInViewport(south, west, north, east, page, size)

    @GetMapping("/me")
    fun myMarkers(auth: Authentication) = service.myMarkers(auth)

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: MarkerCreateRequest, auth: Authentication) = service.createMarker(req, auth)

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun update(
        @PathVariable id: String,
        @RequestBody req: MarkerUpdateRequest,
        auth: Authentication
    ) = service.updateMarker(id, req, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication) = service.deleteMarker(id, auth)
}
