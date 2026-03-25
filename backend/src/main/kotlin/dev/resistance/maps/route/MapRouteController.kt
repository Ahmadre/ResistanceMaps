package dev.resistance.maps.route

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/routes")
class MapRouteController(private val service: MapRouteService) {

    @GetMapping("/public")
    fun listPublic(): List<MapRoute> = service.publicRoutes()

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun myRoutes(auth: Authentication): List<MapRoute> = service.getAccessibleRoutes(auth)

    @GetMapping("/{id}")
    fun get(@PathVariable id: String): ResponseEntity<MapRoute> =
        service.getRoute(id)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: CreateRouteRequest, auth: Authentication): MapRoute =
        service.createRoute(req, auth)

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun update(@PathVariable id: String, @RequestBody req: UpdateRouteRequest, auth: Authentication): MapRoute =
        service.updateRoute(id, req, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.deleteRoute(id, auth)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun generateToken(@PathVariable id: String, @RequestParam(defaultValue = "false") isPublic: Boolean, auth: Authentication): MapRoute =
        service.generateShareToken(id, isPublic, auth)

    @DeleteMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun revokeToken(@PathVariable id: String, @RequestParam(defaultValue = "false") isPublic: Boolean, auth: Authentication): MapRoute =
        service.revokeShareToken(id, isPublic, auth)

    @PostMapping("/{id}/verify-password")
    fun verifyPassword(@PathVariable id: String, @RequestBody req: PasswordVerifyRequest): ResponseEntity<Map<String, Boolean>> {
        val route = service.getRoute(id) ?: return ResponseEntity.notFound().build()
        val valid = service.verifyPassword(route, req.password)
        return ResponseEntity.ok(mapOf("valid" to valid))
    }

    @GetMapping("/shared/{token}")
    fun getByToken(@PathVariable token: String): ResponseEntity<MapRoute> =
        service.getByShareToken(token)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()
}

data class PasswordVerifyRequest(val password: String)
