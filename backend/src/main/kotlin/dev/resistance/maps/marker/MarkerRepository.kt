package dev.resistance.maps.marker

import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.data.mongodb.repository.Query
import java.time.Instant

interface MarkerRepository : MongoRepository<Marker, String> {
    fun findAllByVisibility(visibility: Visibility): List<Marker>
    fun findAllByCreatedBy(createdBy: String): List<Marker>
    fun findAllByGroupId(groupId: String): List<Marker>
    fun findAllByIdIn(ids: Collection<String>): List<Marker>
    fun findByShareToken(token: String): Marker?
    fun findByPublicShareToken(token: String): Marker?
    @Query("{ 'expiresAt': { '\$ne': null, '\$lt': ?0 } }")
    fun findAllByExpiresAtNotNullAndExpiresAtBefore(before: Instant): List<Marker>
    fun findAllByVisibilityAndLatBetweenAndLngBetween(
        visibility: Visibility,
        latStart: Double,
        latEnd: Double,
        lngStart: Double,
        lngEnd: Double,
        pageable: Pageable
    ): Page<Marker>
}
