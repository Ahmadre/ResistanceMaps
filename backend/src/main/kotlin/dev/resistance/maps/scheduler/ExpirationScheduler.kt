package dev.resistance.maps.scheduler

import dev.resistance.maps.maplist.MapListRepository
import dev.resistance.maps.marker.MarkerRepository
import dev.resistance.maps.route.MapRouteRepository
import dev.resistance.maps.share.ShareService
import dev.resistance.maps.share.ResourceType
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.time.Instant

@Component
class ExpirationScheduler(
    private val markerRepo: MarkerRepository,
    private val routeRepo: MapRouteRepository,
    private val listRepo: MapListRepository,
    private val shareService: ShareService,
) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(fixedRate = 60_000) // every minute
    fun cleanupExpiredResources() {
        val now = Instant.now()

        val expiredMarkers = markerRepo.findAllByExpiresAtNotNullAndExpiresAtBefore(now)
        if (expiredMarkers.isNotEmpty()) {
            log.info("Deleting {} expired markers", expiredMarkers.size)
            expiredMarkers.forEach { marker -> marker.id?.let { shareService.removeAllSharesForResource(ResourceType.MARKER, it) } }
            markerRepo.deleteAll(expiredMarkers)
        }

        val expiredRoutes = routeRepo.findAllByExpiresAtNotNullAndExpiresAtBefore(now)
        if (expiredRoutes.isNotEmpty()) {
            log.info("Deleting {} expired routes", expiredRoutes.size)
            expiredRoutes.forEach { route -> route.id?.let { shareService.removeAllSharesForResource(ResourceType.ROUTE, it) } }
            routeRepo.deleteAll(expiredRoutes)
        }

        val expiredLists = listRepo.findAllByExpiresAtNotNullAndExpiresAtBefore(now)
        if (expiredLists.isNotEmpty()) {
            log.info("Deleting {} expired lists", expiredLists.size)
            expiredLists.forEach { list -> list.id?.let { shareService.removeAllSharesForResource(ResourceType.LIST, it) } }
            listRepo.deleteAll(expiredLists)
        }

        shareService.cleanupExpiredShares()
    }
}
