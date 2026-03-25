package dev.resistance.maps.connection

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.CompoundIndex
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("connections")
@CompoundIndex(name = "requester_target_idx", def = "{'requesterId': 1, 'targetId': 1}", unique = true)
data class Connection(
    @Id val id: String? = null,
    @Indexed val requesterId: String,
    @Indexed val targetId: String,
    val status: ConnectionStatus = ConnectionStatus.PENDING,
    val createdAt: Instant = Instant.now(),
)
