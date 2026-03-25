package dev.resistance.maps.route

import dev.resistance.maps.group.GroupMemberRepository
import dev.resistance.maps.group.GroupRole
import dev.resistance.maps.marker.Visibility
import dev.resistance.maps.share.ResourceType
import dev.resistance.maps.share.ShareRepository
import org.springframework.security.core.Authentication
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.*

@Service
class MapRouteService(
    private val repo: MapRouteRepository,
    private val shareRepo: ShareRepository,
    private val groupMemberRepo: GroupMemberRepository,
) {
    private val encoder = BCryptPasswordEncoder()

    fun publicRoutes(): List<MapRoute> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun getRoute(id: String): MapRoute? = repo.findById(id).orElse(null)

    fun getByShareToken(token: String): MapRoute? = repo.findByShareToken(token) ?: repo.findByPublicShareToken(token)

    fun getAccessibleRoutes(auth: Authentication): List<MapRoute> {
        val userId = auth.name
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin) return repo.findAll()

        val own = repo.findAllByCreatedBy(userId)
        val public = repo.findAllByVisibility(Visibility.PUBLIC)
        val sharedIds = shareRepo.findAllBySharedWithUserId(userId)
            .filter { it.resourceType == ResourceType.ROUTE }
            .map { it.resourceId }
        val groupIds = groupMemberRepo.findAllByUserId(userId).map { it.groupId }
        val groupSharedIds = if (groupIds.isNotEmpty()) {
            shareRepo.findAllBySharedWithGroupIdIn(groupIds)
                .filter { it.resourceType == ResourceType.ROUTE }
                .map { it.resourceId }
        } else emptyList()
        val groupRoutes = if (groupIds.isNotEmpty()) {
            groupIds.flatMap { repo.findAllByGroupId(it) }
                .filter { it.visibility == Visibility.PUBLIC || it.createdBy == userId }
        } else emptyList()

        val sharedRoutes = if (sharedIds.isNotEmpty() || groupSharedIds.isNotEmpty()) {
            repo.findAllByIdIn(sharedIds + groupSharedIds)
        } else emptyList()

        return (own + public + sharedRoutes + groupRoutes).distinctBy { it.id }
    }

    fun createRoute(req: CreateRouteRequest, auth: Authentication): MapRoute {
        val route = MapRoute(
            title = req.title,
            description = req.description,
            waypoints = req.waypoints.map { GeoPoint(it.lat, it.lng) },
            visibility = req.visibility ?: Visibility.PUBLIC,
            createdBy = auth.name,
            groupId = req.groupId,
            tags = req.tags?.toSet() ?: emptySet(),
            webLink = req.webLink,
            expiresAt = req.expiresAt,
            passwordHash = req.password?.let { encoder.encode(it) },
        )
        return repo.save(route)
    }

    fun updateRoute(id: String, req: UpdateRouteRequest, auth: Authentication): MapRoute {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Route not found") }
        requireWriteAccess(existing, auth)
        val updated = existing.copy(
            title = req.title ?: existing.title,
            description = req.description ?: existing.description,
            waypoints = req.waypoints?.map { GeoPoint(it.lat, it.lng) } ?: existing.waypoints,
            visibility = req.visibility ?: existing.visibility,
            tags = req.tags?.toSet() ?: existing.tags,
            coverImageId = req.coverImageId ?: existing.coverImageId,
            imageIds = req.imageIds ?: existing.imageIds,
            documentIds = req.documentIds ?: existing.documentIds,
            webLink = req.webLink ?: existing.webLink,
            expiresAt = req.expiresAt ?: existing.expiresAt,
            passwordHash = req.password?.let { encoder.encode(it) } ?: existing.passwordHash,
            updatedAt = Instant.now(),
        )
        return repo.save(updated)
    }

    fun deleteRoute(id: String, auth: Authentication) {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Route not found") }
        requireWriteAccess(existing, auth)
        shareRepo.deleteAllByResourceTypeAndResourceId(ResourceType.ROUTE, id)
        repo.deleteById(id)
    }

    fun generateShareToken(id: String, isPublic: Boolean, auth: Authentication): MapRoute {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Route not found") }
        requireWriteAccess(existing, auth)
        val token = UUID.randomUUID().toString()
        val updated = if (isPublic) existing.copy(publicShareToken = token, updatedAt = Instant.now())
        else existing.copy(shareToken = token, updatedAt = Instant.now())
        return repo.save(updated)
    }

    fun revokeShareToken(id: String, isPublic: Boolean, auth: Authentication): MapRoute {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Route not found") }
        requireWriteAccess(existing, auth)
        val updated = if (isPublic) existing.copy(publicShareToken = null, updatedAt = Instant.now())
        else existing.copy(shareToken = null, updatedAt = Instant.now())
        return repo.save(updated)
    }

    fun verifyPassword(route: MapRoute, password: String): Boolean {
        if (route.passwordHash == null) return true
        return encoder.matches(password, route.passwordHash)
    }

    private fun requireWriteAccess(route: MapRoute, auth: Authentication) {
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin) return
        if (route.createdBy != auth.name) {
            val isGroupAdmin = route.groupId?.let { groupMemberRepo.findByGroupIdAndUserId(it, auth.name) }
                ?.let { it.role == GroupRole.ADMIN || it.role == GroupRole.OWNER }
                ?: false
            if (!isGroupAdmin) throw IllegalAccessException("Not allowed")
        }
    }
}

data class GeoPointRequest(val lat: Double, val lng: Double)

data class CreateRouteRequest(
    val title: String,
    val description: String? = null,
    val waypoints: List<GeoPointRequest> = emptyList(),
    val visibility: Visibility? = null,
    val groupId: String? = null,
    val tags: List<String>? = null,
    val webLink: String? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
)

data class UpdateRouteRequest(
    val title: String? = null,
    val description: String? = null,
    val waypoints: List<GeoPointRequest>? = null,
    val visibility: Visibility? = null,
    val tags: List<String>? = null,
    val coverImageId: String? = null,
    val imageIds: List<String>? = null,
    val documentIds: List<String>? = null,
    val webLink: String? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
)
