package dev.resistance.maps.marker

import org.springframework.data.mongodb.repository.MongoRepository

interface MarkerRepository : MongoRepository<Marker, String> {
    fun findAllByVisibility(visibility: Visibility): List<Marker>
    fun findAllByCreatedBy(createdBy: String): List<Marker>
}
