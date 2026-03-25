package dev.resistance.maps.marker

import dev.resistance.maps.group.GroupService
import dev.resistance.maps.share.ResourceType
import dev.resistance.maps.share.ShareRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.security.core.Authentication
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.UUID

@Service
class MarkerService(
    private val repo: MarkerRepository,
    private val groupService: GroupService,
    private val shareRepo: ShareRepository,
) {
    private val passwordEncoder = BCryptPasswordEncoder()

    fun publicMarkers(): List<Marker> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun publicMarkersInViewport(south: Double, west: Double, north: Double, east: Double, page: Int, size: Int): Page<Marker> {
        val p = PageRequest.of(page, size)
        val latStart = minOf(south, north)
        val latEnd = maxOf(south, north)
        val lngStart = minOf(west, east)
        val lngEnd = maxOf(west, east)
        return repo.findAllByVisibilityAndLatBetweenAndLngBetween(Visibility.PUBLIC, latStart, latEnd, lngStart, lngEnd, p)
    }

    fun getMarker(id: String): Marker? = repo.findById(id).orElse(null)

    fun getByShareToken(token: String): Marker? =
        repo.findByShareToken(token) ?: repo.findByPublicShareToken(token)

    fun getAccessibleMarkers(auth: Authentication): List<Marker> {
        if (isSuperAdmin(auth)) return repo.findAll()

        val userId = auth.name
        val own = repo.findAllByCreatedBy(userId)
        val public = repo.findAllByVisibility(Visibility.PUBLIC)

        val groupIds = groupService.getMyGroups(auth).mapNotNull { it.id }
        val groupMarkers = groupIds.flatMap { repo.findAllByGroupId(it) }

        val userShares = shareRepo.findAllBySharedWithUserId(userId)
            .filter { it.resourceType == ResourceType.MARKER }
        val groupShares = if (groupIds.isNotEmpty()) {
            shareRepo.findAllBySharedWithGroupIdIn(groupIds)
                .filter { it.resourceType == ResourceType.MARKER }
        } else emptyList()
        val sharedIds = (userShares + groupShares).map { it.resourceId }.distinct()
        val sharedMarkers = if (sharedIds.isNotEmpty()) repo.findAllByIdIn(sharedIds) else emptyList()

        return (own + public + groupMarkers + sharedMarkers)
            .distinctBy { it.id }
    }

    fun createMarker(request: MarkerCreateRequest, auth: Authentication): Marker {
        request.groupId?.let { gid ->
            require(groupService.isGroupMember(gid, auth.name)) { "Not a member of this group" }
        }
        val marker = Marker(
            title = request.title,
            description = request.description,
            lat = request.lat,
            lng = request.lng,
            visibility = request.visibility ?: Visibility.PUBLIC,
            createdBy = auth.name,
            tags = request.tags?.toSet() ?: emptySet(),
            groupId = request.groupId,
            webLink = request.webLink,
            expiresAt = request.expiresAt,
            passwordHash = request.password?.let { passwordEncoder.encode(it) },
            coverImageId = request.coverImageId,
            imageIds = request.imageIds ?: emptyList(),
            documentIds = request.documentIds ?: emptyList(),
        )
        return repo.save(marker)
    }

    fun updateMarker(id: String, request: MarkerUpdateRequest, auth: Authentication): Marker {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        requireWriteAccess(existing, auth)
        val updated = existing.copy(
            title = request.title ?: existing.title,
            description = request.description ?: existing.description,
            lat = request.lat ?: existing.lat,
            lng = request.lng ?: existing.lng,
            visibility = request.visibility ?: existing.visibility,
            tags = request.tags?.toSet() ?: existing.tags,
            webLink = request.webLink ?: existing.webLink,
            expiresAt = request.expiresAt ?: existing.expiresAt,
            passwordHash = request.password?.let { passwordEncoder.encode(it) } ?: existing.passwordHash,
            coverImageId = request.coverImageId ?: existing.coverImageId,
            imageIds = request.imageIds ?: existing.imageIds,
            documentIds = request.documentIds ?: existing.documentIds,
            updatedAt = Instant.now(),
        )
        return repo.save(updated)
    }

    fun deleteMarker(id: String, auth: Authentication) {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        requireWriteAccess(existing, auth)
        repo.deleteById(id)
    }

    fun generateShareToken(id: String, isPublic: Boolean, auth: Authentication): Marker {
        val marker = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        requireWriteAccess(marker, auth)
        val updated = if (isPublic) marker.copy(publicShareToken = UUID.randomUUID().toString())
        else marker.copy(shareToken = UUID.randomUUID().toString())
        return repo.save(updated)
    }

    fun revokeShareToken(id: String, isPublic: Boolean, auth: Authentication): Marker {
        val marker = repo.findById(id).orElseThrow { NoSuchElementException("Marker not found") }
        requireWriteAccess(marker, auth)
        val updated = if (isPublic) marker.copy(publicShareToken = null) else marker.copy(shareToken = null)
        return repo.save(updated)
    }

    fun verifyPassword(marker: Marker, password: String): Boolean {
        val hash = marker.passwordHash ?: return true
        return passwordEncoder.matches(password, hash)
    }

    private fun requireWriteAccess(marker: Marker, auth: Authentication) {
        if (isSuperAdmin(auth)) return
        if (marker.createdBy == auth.name) return
        marker.groupId?.let { gid ->
            if (groupService.isGroupAdmin(gid, auth.name)) return
        }
        throw IllegalAccessException("Not allowed to modify this marker")
    }

    private fun isSuperAdmin(auth: Authentication): Boolean =
        auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
}

data class MarkerCreateRequest(
    val title: String,
    val description: String? = null,
    val lat: Double,
    val lng: Double,
    val tags: List<String>? = null,
    val visibility: Visibility? = null,
    val groupId: String? = null,
    val webLink: String? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
    val coverImageId: String? = null,
    val imageIds: List<String>? = null,
    val documentIds: List<String>? = null,
)

data class MarkerUpdateRequest(
    val title: String? = null,
    val description: String? = null,
    val lat: Double? = null,
    val lng: Double? = null,
    val tags: List<String>? = null,
    val visibility: Visibility? = null,
    val webLink: String? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
    val coverImageId: String? = null,
    val imageIds: List<String>? = null,
    val documentIds: List<String>? = null,
)
