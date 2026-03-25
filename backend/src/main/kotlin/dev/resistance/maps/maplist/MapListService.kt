package dev.resistance.maps.maplist

import dev.resistance.maps.group.GroupMemberRepository
import dev.resistance.maps.marker.Visibility
import dev.resistance.maps.share.ResourceType
import dev.resistance.maps.share.ShareRepository
import org.springframework.security.core.Authentication
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.*

@Service
class MapListService(
    private val repo: MapListRepository,
    private val shareRepo: ShareRepository,
    private val groupMemberRepo: GroupMemberRepository,
) {
    private val encoder = BCryptPasswordEncoder()

    fun publicLists(): List<MapList> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun getList(id: String): MapList? = repo.findById(id).orElse(null)

    fun getByShareToken(token: String): MapList? = repo.findByShareToken(token) ?: repo.findByPublicShareToken(token)

    fun getAccessibleLists(auth: Authentication): List<MapList> {
        val userId = auth.name
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin) return repo.findAll()

        val own = repo.findAllByCreatedBy(userId)
        val public = publicLists()
        val groupIds = groupMemberRepo.findAllByUserId(userId).map { it.groupId }
        val groupLists = if (groupIds.isNotEmpty()) groupIds.flatMap { repo.findAllByGroupId(it) } else emptyList()
        val userShares = shareRepo.findAllBySharedWithUserId(userId)
            .filter { it.resourceType == ResourceType.LIST }.map { it.resourceId }
        val groupShares = if (groupIds.isNotEmpty()) shareRepo.findAllBySharedWithGroupIdIn(groupIds)
            .filter { it.resourceType == ResourceType.LIST }.map { it.resourceId } else emptyList()
        val sharedLists = (userShares + groupShares).distinct().let { if (it.isNotEmpty()) repo.findAllByIdIn(it) else emptyList() }
        return (own + public + groupLists + sharedLists).distinctBy { it.id }
    }

    fun createList(req: CreateListRequest, auth: Authentication): MapList {
        return repo.save(
            MapList(
                title = req.title,
                description = req.description,
                visibility = req.visibility ?: Visibility.PUBLIC,
                createdBy = auth.name,
                groupId = req.groupId,
                markerIds = req.markerIds ?: emptyList(),
                routeIds = req.routeIds ?: emptyList(),
                expiresAt = req.expiresAt,
                passwordHash = req.password?.let { encoder.encode(it) },
            )
        )
    }

    fun updateList(id: String, req: UpdateListRequest, auth: Authentication): MapList {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("List not found") }
        requireWriteAccess(existing, auth)
        val updated = existing.copy(
            title = req.title ?: existing.title,
            description = req.description ?: existing.description,
            visibility = req.visibility ?: existing.visibility,
            markerIds = req.markerIds ?: existing.markerIds,
            routeIds = req.routeIds ?: existing.routeIds,
            expiresAt = req.expiresAt ?: existing.expiresAt,
            passwordHash = req.password?.let { encoder.encode(it) } ?: existing.passwordHash,
            updatedAt = Instant.now(),
        )
        return repo.save(updated)
    }

    fun deleteList(id: String, auth: Authentication) {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("List not found") }
        requireWriteAccess(existing, auth)
        shareRepo.deleteAllByResourceTypeAndResourceId(ResourceType.LIST, id)
        repo.deleteById(id)
    }

    fun generateShareToken(id: String, isPublic: Boolean, auth: Authentication): MapList {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("List not found") }
        requireWriteAccess(existing, auth)
        val token = UUID.randomUUID().toString()
        val updated = if (isPublic) existing.copy(publicShareToken = token, updatedAt = Instant.now())
        else existing.copy(shareToken = token, updatedAt = Instant.now())
        return repo.save(updated)
    }

    fun revokeShareToken(id: String, isPublic: Boolean, auth: Authentication): MapList {
        val existing = repo.findById(id).orElseThrow { NoSuchElementException("List not found") }
        requireWriteAccess(existing, auth)
        val updated = if (isPublic) existing.copy(publicShareToken = null, updatedAt = Instant.now())
        else existing.copy(shareToken = null, updatedAt = Instant.now())
        return repo.save(updated)
    }

    fun verifyPassword(list: MapList, password: String): Boolean {
        if (list.passwordHash == null) return true
        return encoder.matches(password, list.passwordHash)
    }

    private fun requireWriteAccess(list: MapList, auth: Authentication) {
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin) return
        if (list.createdBy == auth.name) return
        list.groupId?.let { gid ->
            val member = groupMemberRepo.findByGroupIdAndUserId(gid, auth.name)
            if (member != null && (member.role == dev.resistance.maps.group.GroupRole.ADMIN || member.role == dev.resistance.maps.group.GroupRole.OWNER)) return
        }
        throw IllegalAccessException("Not allowed to modify this list")
    }
}

data class CreateListRequest(
    val title: String,
    val description: String? = null,
    val visibility: Visibility? = null,
    val groupId: String? = null,
    val markerIds: List<String>? = null,
    val routeIds: List<String>? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
)

data class UpdateListRequest(
    val title: String? = null,
    val description: String? = null,
    val visibility: Visibility? = null,
    val markerIds: List<String>? = null,
    val routeIds: List<String>? = null,
    val expiresAt: Instant? = null,
    val password: String? = null,
)
