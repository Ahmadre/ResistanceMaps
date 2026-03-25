package dev.resistance.maps.maplist

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/lists")
class MapListController(private val service: MapListService) {

    @GetMapping("/public")
    fun listPublic(): List<MapList> = service.publicLists()

    @GetMapping("/{id}")
    fun get(@PathVariable id: String): ResponseEntity<MapList> =
        service.getList(id)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: CreateListRequest, auth: Authentication): MapList =
        service.createList(req, auth)

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun update(@PathVariable id: String, @RequestBody req: UpdateListRequest, auth: Authentication): MapList =
        service.updateList(id, req, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.deleteList(id, auth)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun generateToken(@PathVariable id: String, @RequestParam(defaultValue = "false") isPublic: Boolean, auth: Authentication): MapList =
        service.generateShareToken(id, isPublic, auth)

    @DeleteMapping("/{id}/share-token")
    @PreAuthorize("isAuthenticated()")
    fun revokeToken(@PathVariable id: String, @RequestParam(defaultValue = "false") isPublic: Boolean, auth: Authentication): MapList =
        service.revokeShareToken(id, isPublic, auth)

    @PostMapping("/{id}/verify-password")
    fun verifyPassword(@PathVariable id: String, @RequestBody req: PasswordVerifyRequest): ResponseEntity<Map<String, Boolean>> {
        val list = service.getList(id) ?: return ResponseEntity.notFound().build()
        val valid = service.verifyPassword(list, req.password)
        return ResponseEntity.ok(mapOf("valid" to valid))
    }

    @GetMapping("/shared/{token}")
    fun getByToken(@PathVariable token: String): ResponseEntity<MapList> =
        service.getByShareToken(token)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()
}

data class PasswordVerifyRequest(val password: String)
