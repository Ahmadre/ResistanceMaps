package dev.resistance.maps.group

import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/groups")
class GroupController(private val service: GroupService) {

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    fun create(@RequestBody req: CreateGroupRequest, auth: Authentication): Group =
        service.createGroup(req.name, req.description, auth)

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun myGroups(auth: Authentication): List<Group> = service.getMyGroups(auth)

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    fun search(
        @RequestParam q: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
    ) = service.searchGroups(q, page, size)

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun get(@PathVariable id: String): ResponseEntity<Group> =
        service.getGroup(id)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @PatchMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun update(@PathVariable id: String, @RequestBody req: UpdateGroupRequest, auth: Authentication): Group =
        service.updateGroup(id, req.name, req.description, auth)

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.deleteGroup(id, auth)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/{id}/members")
    @PreAuthorize("isAuthenticated()")
    fun members(@PathVariable id: String, auth: Authentication): List<GroupMember> {
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (!isSuperAdmin) {
            service.getMembership(id, auth.name) ?: throw IllegalAccessException("Not a member of this group")
        }
        return service.getMembers(id)
    }

    @PostMapping("/{id}/members")
    @PreAuthorize("isAuthenticated()")
    fun addMember(@PathVariable id: String, @RequestBody req: AddMemberRequest, auth: Authentication): GroupMember =
        service.addMember(id, req.userId, auth)

    @DeleteMapping("/{id}/members/{userId}")
    @PreAuthorize("isAuthenticated()")
    fun removeMember(@PathVariable id: String, @PathVariable userId: String, auth: Authentication): ResponseEntity<Void> {
        service.removeMember(id, userId, auth)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/{id}/members/{userId}/promote")
    @PreAuthorize("isAuthenticated()")
    fun promote(@PathVariable id: String, @PathVariable userId: String, auth: Authentication): GroupMember =
        service.promoteMember(id, userId, auth)

    @PostMapping("/{id}/members/{userId}/demote")
    @PreAuthorize("isAuthenticated()")
    fun demote(@PathVariable id: String, @PathVariable userId: String, auth: Authentication): GroupMember =
        service.demoteMember(id, userId, auth)
}

data class CreateGroupRequest(val name: String, val description: String? = null)
data class UpdateGroupRequest(val name: String? = null, val description: String? = null)
data class AddMemberRequest(val userId: String)
