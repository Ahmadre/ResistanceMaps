package dev.resistance.maps.file

import org.springframework.data.mongodb.repository.MongoRepository

interface FileMetadataRepository : MongoRepository<FileMetadata, String> {
    fun findAllByUploadedBy(uploadedBy: String): List<FileMetadata>
    fun findAllByIdIn(ids: Collection<String>): List<FileMetadata>
}
