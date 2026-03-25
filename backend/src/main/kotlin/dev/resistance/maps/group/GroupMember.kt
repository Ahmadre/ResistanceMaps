package dev.resistance.maps.group

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.CompoundIndex
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("group_members")
@CompoundIndex(name = "group_user_idx", def = "{'groupId': 1, 'userId': 1}", unique = true)
data class GroupMember(
    @Id val id: String? = null,
    @Indexed val groupId: String,
    @Indexed val userId: String,
    val role: GroupRole = GroupRole.MEMBER,
    val joinedAt: Instant = Instant.now(),
)
