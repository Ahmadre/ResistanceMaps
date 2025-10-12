package dev.resistance.maps.mq

import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/heavy")
class HeavyTaskController(private val publisher: HeavyTaskPublisher) {
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','SUPERADMIN')")
    fun enqueue(): Map<String, String> {
        publisher.publish("compute-something")
        return mapOf("status" to "queued")
    }
}
