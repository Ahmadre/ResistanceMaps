package dev.resistance.maps.marker

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

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
    @PreAuthorize("isAuthenticated()")
    fun myMarkers(auth: Authentication) = service.getAccessibleMarkers(auth)

    @GetMapping("/{id}")
    fun getMarker(@PathVariable id: String): ResponseEntity<Marker> =
        service.getMarker(id)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: MarkerCreateRequest, auth: Authentication) = service.createMarker(req, auth)

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun update(
        @PathVariable id: String,
        @RequestBody req: MarkerUpdateRequest,
        auth: Authentication,
    ) = service.updateMarker(id, req, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.deleteMarker(id, auth)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun generateToken(
        @PathVariable id: String,
        @RequestParam(defaultValue = "false") isPublic: Boolean,
        auth: Authentication,
    ): Marker = service.generateShareToken(id, isPublic, auth)

    @DeleteMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun revokeToken(
        @PathVariable id: String,
        @RequestParam(defaultValue = "false") isPublic: Boolean,
        auth: Authentication,
    ): Marker = service.revokeShareToken(id, isPublic, auth)

    @PostMapping("/{id}/verify-password")
    fun verifyPassword(@PathVariable id: String, @RequestBody req: PasswordVerifyRequest): ResponseEntity<Map<String, Boolean>> {
        val marker = service.getMarker(id) ?: return ResponseEntity.notFound().build()
        val valid = service.verifyPassword(marker, req.password)
        return ResponseEntity.ok(mapOf("valid" to valid))
    }

    @GetMapping("/shared/{token}")
    fun getByToken(@PathVariable token: String): ResponseEntity<Marker> =
        service.getByShareToken(token)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()
}

data class PasswordVerifyRequest(val password: String)
