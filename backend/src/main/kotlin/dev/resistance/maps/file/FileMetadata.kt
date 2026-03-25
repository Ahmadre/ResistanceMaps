package dev.resistance.maps.file

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document("files")
data class FileMetadata(
    @Id val id: String? = null,
    val originalName: String,
    val contentType: String,
    val size: Long,
    val storagePath: String,
    @Indexed val uploadedBy: String,
    val createdAt: Instant = Instant.now(),
)
