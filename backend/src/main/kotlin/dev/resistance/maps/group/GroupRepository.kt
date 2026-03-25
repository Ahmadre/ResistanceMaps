package dev.resistance.maps.group

import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.mongodb.repository.MongoRepository

interface GroupRepository : MongoRepository<Group, String> {
    fun findByNameContainingIgnoreCase(name: String, pageable: Pageable): Page<Group>
    fun findByIdIn(ids: Collection<String>): List<Group>
}

interface GroupMemberRepository : MongoRepository<GroupMember, String> {
    fun findAllByGroupId(groupId: String): List<GroupMember>
    fun findAllByUserId(userId: String): List<GroupMember>
    fun findByGroupIdAndUserId(groupId: String, userId: String): GroupMember?
    fun findAllByGroupIdIn(groupIds: Collection<String>): List<GroupMember>
    fun findAllByGroupIdAndRole(groupId: String, role: GroupRole): List<GroupMember>
    fun countByGroupIdAndRoleIn(groupId: String, roles: Collection<GroupRole>): Long
    fun deleteByGroupIdAndUserId(groupId: String, userId: String)
}
