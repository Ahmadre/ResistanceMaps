package dev.resistance.maps.connection

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/connections")
class ConnectionController(private val service: ConnectionService) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun invite(@RequestBody req: InviteRequest, auth: Authentication): Connection =
        service.sendInvitation(auth, req.usernameOrEmail)

    @GetMapping("/pending")
    @PreAuthorize("isAuthenticated()")
    fun pending(auth: Authentication): List<Connection> = service.getPendingInvitations(auth)

    @GetMapping("/sent")
    @PreAuthorize("isAuthenticated()")
    fun sent(auth: Authentication): List<Connection> = service.getSentInvitations(auth)

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    fun accepted(auth: Authentication): List<Connection> = service.getAcceptedConnections(auth)

    @PostMapping("/{id}/accept")
    @PreAuthorize("isAuthenticated()")
    fun accept(@PathVariable id: String, auth: Authentication): Connection =
        service.acceptInvitation(id, auth)

    @PostMapping("/{id}/reject")
    @PreAuthorize("isAuthenticated()")
    fun reject(@PathVariable id: String, auth: Authentication): Connection =
        service.rejectInvitation(id, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun remove(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.removeConnection(id, auth)
        return ResponseEntity.noContent().build()
    }
}

data class InviteRequest(val usernameOrEmail: String)
