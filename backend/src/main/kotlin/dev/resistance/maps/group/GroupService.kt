package dev.resistance.maps.group

import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service

@Service
class GroupService(
    private val groupRepo: GroupRepository,
    private val memberRepo: GroupMemberRepository,
) {

    fun createGroup(name: String, description: String?, auth: Authentication): Group {
        val group = groupRepo.save(Group(name = name, description = description, createdBy = auth.name))
        memberRepo.save(GroupMember(groupId = group.id!!, userId = auth.name, role = GroupRole.OWNER))
        return group
    }

    fun getGroup(id: String): Group? = groupRepo.findById(id).orElse(null)

    fun getMyGroups(auth: Authentication): List<Group> {
        val memberships = memberRepo.findAllByUserId(auth.name)
        val groupIds = memberships.map { it.groupId }
        return if (groupIds.isEmpty()) emptyList() else groupRepo.findByIdIn(groupIds)
    }

    fun searchGroups(query: String, page: Int, size: Int): Page<Group> =
        groupRepo.findByNameContainingIgnoreCase(query, PageRequest.of(page, size))

    fun getMembers(groupId: String): List<GroupMember> = memberRepo.findAllByGroupId(groupId)

    fun getMembership(groupId: String, userId: String): GroupMember? =
        memberRepo.findByGroupIdAndUserId(groupId, userId)

    fun addMember(groupId: String, userId: String, auth: Authentication): GroupMember {
        requireGroupAdmin(groupId, auth)
        val existing = memberRepo.findByGroupIdAndUserId(groupId, userId)
        if (existing != null) throw IllegalStateException("User is already a member")
        return memberRepo.save(GroupMember(groupId = groupId, userId = userId, role = GroupRole.MEMBER))
    }

    fun removeMember(groupId: String, userId: String, auth: Authentication) {
        requireGroupAdmin(groupId, auth)
        val member = memberRepo.findByGroupIdAndUserId(groupId, userId)
            ?: throw NoSuchElementException("Member not found")
        if (member.role == GroupRole.OWNER) throw IllegalStateException("Cannot remove the group owner")
        memberRepo.deleteByGroupIdAndUserId(groupId, userId)
    }

    fun promoteMember(groupId: String, userId: String, auth: Authentication): GroupMember {
        requireGroupAdmin(groupId, auth)
        val member = memberRepo.findByGroupIdAndUserId(groupId, userId)
            ?: throw NoSuchElementException("Member not found")
        if (member.role == GroupRole.ADMIN || member.role == GroupRole.OWNER) {
            throw IllegalStateException("User is already an admin or owner")
        }
        val updated = member.copy(role = GroupRole.ADMIN)
        return memberRepo.save(updated)
    }

    fun demoteMember(groupId: String, userId: String, auth: Authentication): GroupMember {
        requireGroupAdmin(groupId, auth)
        val member = memberRepo.findByGroupIdAndUserId(groupId, userId)
            ?: throw NoSuchElementException("Member not found")
        if (member.role == GroupRole.OWNER) throw IllegalStateException("Cannot demote the owner")
        if (member.role == GroupRole.MEMBER) throw IllegalStateException("User is already a member")
        // Ensure at least one admin remains
        val adminCount = memberRepo.countByGroupIdAndRoleIn(groupId, listOf(GroupRole.ADMIN, GroupRole.OWNER))
        if (adminCount <= 1) throw IllegalStateException("Cannot demote the last admin")
        val updated = member.copy(role = GroupRole.MEMBER)
        return memberRepo.save(updated)
    }

    fun updateGroup(id: String, name: String?, description: String?, auth: Authentication): Group {
        requireGroupAdmin(id, auth)
        val group = groupRepo.findById(id).orElseThrow { NoSuchElementException("Group not found") }
        val updated = group.copy(
            name = name ?: group.name,
            description = description ?: group.description,
        )
        return groupRepo.save(updated)
    }

    fun deleteGroup(id: String, auth: Authentication) {
        val member = memberRepo.findByGroupIdAndUserId(id, auth.name)
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (member?.role != GroupRole.OWNER && !isSuperAdmin) {
            throw IllegalAccessException("Only the owner or superadmin can delete a group")
        }
        memberRepo.findAllByGroupId(id).forEach { memberRepo.delete(it) }
        groupRepo.deleteById(id)
    }

    fun isGroupAdmin(groupId: String, userId: String): Boolean {
        val member = memberRepo.findByGroupIdAndUserId(groupId, userId) ?: return false
        return member.role == GroupRole.ADMIN || member.role == GroupRole.OWNER
    }

    fun isGroupMember(groupId: String, userId: String): Boolean =
        memberRepo.findByGroupIdAndUserId(groupId, userId) != null

    private fun requireGroupAdmin(groupId: String, auth: Authentication) {
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (isSuperAdmin) return
        if (!isGroupAdmin(groupId, auth.name)) {
            throw IllegalAccessException("You must be a group admin")
        }
    }
}
