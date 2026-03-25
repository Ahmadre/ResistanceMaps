package dev.resistance.maps.connection

import dev.resistance.maps.user.UserProfileService
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class ConnectionService(
    private val repo: ConnectionRepository,
    private val userProfileService: UserProfileService,
) {

    fun sendInvitation(auth: Authentication, targetUsernameOrEmail: String): Connection {
        val target = userProfileService.getByUsername(targetUsernameOrEmail)
            ?: userProfileService.getByEmail(targetUsernameOrEmail)
            ?: throw NoSuchElementException("User not found")

        if (target.userId == auth.name) throw IllegalStateException("Cannot connect with yourself")

        val existing = repo.findByRequesterIdAndTargetId(auth.name, target.userId)
            ?: repo.findByRequesterIdAndTargetId(target.userId, auth.name)
        if (existing != null) throw IllegalStateException("Connection already exists")

        return repo.save(Connection(requesterId = auth.name, targetId = target.userId))
    }

    fun acceptInvitation(id: String, auth: Authentication): Connection {
        val conn = repo.findById(id).orElseThrow { NoSuchElementException("Connection not found") }
        if (conn.targetId != auth.name) throw IllegalAccessException("Not your invitation")
        if (conn.status != ConnectionStatus.PENDING) throw IllegalStateException("Already processed")
        return repo.save(conn.copy(status = ConnectionStatus.ACCEPTED))
    }

    fun rejectInvitation(id: String, auth: Authentication): Connection {
        val conn = repo.findById(id).orElseThrow { NoSuchElementException("Connection not found") }
        if (conn.targetId != auth.name) throw IllegalAccessException("Not your invitation")
        if (conn.status != ConnectionStatus.PENDING) throw IllegalStateException("Already processed")
        return repo.save(conn.copy(status = ConnectionStatus.REJECTED))
    }

    fun removeConnection(id: String, auth: Authentication) {
        val conn = repo.findById(id).orElseThrow { NoSuchElementException("Connection not found") }
        if (conn.requesterId != auth.name && conn.targetId != auth.name) {
            throw IllegalAccessException("Not your connection")
        }
        repo.delete(conn)
    }

    fun getPendingInvitations(auth: Authentication): List<Connection> =
        repo.findAllByTargetIdAndStatus(auth.name, ConnectionStatus.PENDING)

    fun getSentInvitations(auth: Authentication): List<Connection> =
        repo.findAllByRequesterIdAndStatus(auth.name, ConnectionStatus.PENDING)

    fun getAcceptedConnections(auth: Authentication): List<Connection> =
        repo.findAllAcceptedForUser(auth.name)

    fun areConnected(userId1: String, userId2: String): Boolean =
        repo.findAccepted(userId1, userId2) != null
}
