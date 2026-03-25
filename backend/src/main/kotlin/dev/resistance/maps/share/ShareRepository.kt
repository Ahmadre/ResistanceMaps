package dev.resistance.maps.share

import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.data.mongodb.repository.Query
import java.time.Instant

interface ShareRepository : MongoRepository<Share, String> {
    fun findAllByResourceTypeAndResourceId(type: ResourceType, resourceId: String): List<Share>
    fun findAllBySharedWithUserId(userId: String): List<Share>
    fun findAllBySharedWithGroupIdIn(groupIds: Collection<String>): List<Share>
    @Query("{ 'expiresAt': { '\$ne': null, '\$lt': ?0 } }")
    fun findAllByExpiresAtNotNullAndExpiresAtBefore(before: Instant): List<Share>
    fun deleteAllByResourceTypeAndResourceId(type: ResourceType, resourceId: String)
}
