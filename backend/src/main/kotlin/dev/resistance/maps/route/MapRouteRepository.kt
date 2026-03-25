package dev.resistance.maps.route

import dev.resistance.maps.marker.Visibility
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.mongodb.repository.MongoRepository
import java.time.Instant

interface MapRouteRepository : MongoRepository<MapRoute, String> {
    fun findAllByVisibility(visibility: Visibility): List<MapRoute>
    fun findAllByCreatedBy(createdBy: String): List<MapRoute>
    fun findAllByGroupId(groupId: String): List<MapRoute>
    fun findAllByIdIn(ids: Collection<String>): List<MapRoute>
    fun findByShareToken(token: String): MapRoute?
    fun findByPublicShareToken(token: String): MapRoute?
    fun findAllByVisibilityAndExpiresAtBefore(visibility: Visibility, before: Instant): List<MapRoute>
    fun findAllByExpiresAtNotNullAndExpiresAtBefore(before: Instant): List<MapRoute>
    fun findAllByVisibility(visibility: Visibility, pageable: Pageable): Page<MapRoute>
}
