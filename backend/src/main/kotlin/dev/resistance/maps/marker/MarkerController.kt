package dev.resistance.maps.marker

import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/markers")
class MarkerController(private val service: MarkerService) {

    @GetMapping("/public")
    fun listPublic(): List<Marker> = service.publicMarkers()

    @GetMapping("/me")
    fun myMarkers(auth: Authentication) = service.myMarkers(auth)

    @PostMapping
    @PreAuthorize("hasAnyRole('USER','INTERN','ADMIN','SUPERADMIN')")
    fun create(@RequestBody req: MarkerCreateRequest, auth: Authentication) = service.createMarker(req, auth)
}
