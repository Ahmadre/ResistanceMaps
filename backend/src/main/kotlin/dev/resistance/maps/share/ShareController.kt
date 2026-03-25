package dev.resistance.maps.share

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.time.Instant

@RestController
@RequestMapping("/api/shares")
class ShareController(private val service: ShareService) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: CreateShareRequest, auth: Authentication): Share {
        return if (req.sharedWithUserId != null) {
            service.shareWithUser(req.resourceType, req.resourceId, req.sharedWithUserId, req.expiresAt, auth)
        } else if (req.sharedWithGroupId != null) {
            service.shareWithGroup(req.resourceType, req.resourceId, req.sharedWithGroupId, req.expiresAt, auth)
        } else {
            throw IllegalArgumentException("Must specify sharedWithUserId or sharedWithGroupId")
        }
    }

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    fun list(
        @RequestParam resourceType: ResourceType,
        @RequestParam resourceId: String,
    ): List<Share> = service.getSharesForResource(resourceType, resourceId)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun remove(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.removeShare(id, auth)
        return ResponseEntity.noContent().build()
    }
}

data class CreateShareRequest(
    val resourceType: ResourceType,
    val resourceId: String,
    val sharedWithUserId: String? = null,
    val sharedWithGroupId: String? = null,
    val expiresAt: Instant? = null,
)
