package dev.resistance.maps.share

import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.time.Instant

@Service
class ShareService(private val repo: ShareRepository) {

    fun shareWithUser(resourceType: ResourceType, resourceId: String, userId: String, expiresAt: Instant?, auth: Authentication): Share =
        repo.save(Share(resourceType = resourceType, resourceId = resourceId, sharedWithUserId = userId, expiresAt = expiresAt, createdBy = auth.name))

    fun shareWithGroup(resourceType: ResourceType, resourceId: String, groupId: String, expiresAt: Instant?, auth: Authentication): Share =
        repo.save(Share(resourceType = resourceType, resourceId = resourceId, sharedWithGroupId = groupId, expiresAt = expiresAt, createdBy = auth.name))

    fun getSharesForResource(resourceType: ResourceType, resourceId: String): List<Share> =
        repo.findAllByResourceTypeAndResourceId(resourceType, resourceId)

    fun removeShare(shareId: String, auth: Authentication) {
        val share = repo.findById(shareId).orElseThrow { NoSuchElementException("Share not found") }
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (share.createdBy != auth.name && !isSuperAdmin) throw IllegalAccessException("Not allowed")
        repo.delete(share)
    }

    fun removeAllSharesForResource(resourceType: ResourceType, resourceId: String) =
        repo.deleteAllByResourceTypeAndResourceId(resourceType, resourceId)

    fun cleanupExpiredShares() {
        val expired = repo.findAllByExpiresAtNotNullAndExpiresAtBefore(Instant.now())
        if (expired.isNotEmpty()) repo.deleteAll(expired)
    }

    fun hasAccess(resourceType: ResourceType, resourceId: String, userId: String, groupIds: List<String>): Boolean {
        val shares = repo.findAllByResourceTypeAndResourceId(resourceType, resourceId)
        return shares.any { share ->
            val notExpired = share.expiresAt == null || share.expiresAt.isAfter(Instant.now())
            notExpired && (share.sharedWithUserId == userId || groupIds.contains(share.sharedWithGroupId))
        }
    }
}
