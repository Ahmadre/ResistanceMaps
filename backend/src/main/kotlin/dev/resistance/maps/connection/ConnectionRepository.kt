package dev.resistance.maps.connection

import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.data.mongodb.repository.Query

interface ConnectionRepository : MongoRepository<Connection, String> {
    fun findByRequesterIdAndTargetId(requesterId: String, targetId: String): Connection?
    fun findAllByTargetIdAndStatus(targetId: String, status: ConnectionStatus): List<Connection>
    fun findAllByRequesterIdAndStatus(requesterId: String, status: ConnectionStatus): List<Connection>

    @Query("{\$or: [{'requesterId': ?0, 'status': 'ACCEPTED'}, {'targetId': ?0, 'status': 'ACCEPTED'}]}")
    fun findAllAcceptedForUser(userId: String): List<Connection>

    @Query("{\$or: [{'requesterId': ?0, 'targetId': ?1, 'status': 'ACCEPTED'}, {'requesterId': ?1, 'targetId': ?0, 'status': 'ACCEPTED'}]}")
    fun findAccepted(userId1: String, userId2: String): Connection?

    @Query("{\$or: [{'requesterId': ?0}, {'targetId': ?0}]}")
    fun findAllForUser(userId: String): List<Connection>
}
