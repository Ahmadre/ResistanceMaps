package dev.resistance.maps.maplist

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
) {
    private val encoder = BCryptPasswordEncoder()

    fun publicLists(): List<MapList> = repo.findAllByVisibility(Visibility.PUBLIC)

    fun getList(id: String): MapList? = repo.findById(id).orElse(null)

    fun getByShareToken(token: String): MapList? = repo.findByShareToken(token) ?: repo.findByPublicShareToken(token)

    fun createList(req: CreateListRequest, auth: Authentication): MapList {
        return repo.save(
            MapList(
                title = req.title,
                description = req.description,
                visibility = req.visibility ?: Visibility.PUBLIC,
                createdBy = auth.name,
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
        if (list.createdBy != auth.name) throw IllegalAccessException("Not allowed")
    }
}

data class CreateListRequest(
    val title: String,
    val description: String? = null,
    val visibility: Visibility? = null,
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
