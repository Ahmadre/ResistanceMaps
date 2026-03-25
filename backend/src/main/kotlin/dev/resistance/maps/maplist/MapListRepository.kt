package dev.resistance.maps.maplist

import dev.resistance.maps.marker.Visibility
import org.springframework.data.mongodb.repository.MongoRepository
import java.time.Instant

interface MapListRepository : MongoRepository<MapList, String> {
    fun findAllByVisibility(visibility: Visibility): List<MapList>
    fun findAllByCreatedBy(createdBy: String): List<MapList>
    fun findAllByIdIn(ids: Collection<String>): List<MapList>
    fun findByShareToken(token: String): MapList?
    fun findByPublicShareToken(token: String): MapList?
    fun findAllByExpiresAtNotNullAndExpiresAtBefore(before: Instant): List<MapList>
}
