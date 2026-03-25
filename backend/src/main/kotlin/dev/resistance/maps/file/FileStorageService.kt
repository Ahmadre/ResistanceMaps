package dev.resistance.maps.file

import org.springframework.beans.factory.annotation.Value
import org.springframework.core.io.InputStreamResource
import org.springframework.core.io.Resource
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import java.util.*

@Service
class FileStorageService(
    private val repo: FileMetadataRepository,
    private val s3: S3Client,
    @Value("\${app.s3.bucket}") private val bucket: String,
) {
    companion object {
        val ALLOWED_IMAGE_TYPES = setOf("image/jpeg", "image/png", "image/webp")
        val ALLOWED_DOCUMENT_TYPES = setOf("application/pdf")
        val ALLOWED_TYPES = ALLOWED_IMAGE_TYPES + ALLOWED_DOCUMENT_TYPES
        const val MAX_IMAGES = 10
    }

    fun storeFile(file: MultipartFile, auth: Authentication): FileMetadata {
        val contentType = file.contentType ?: throw IllegalArgumentException("Content type is required")
        if (contentType !in ALLOWED_TYPES) {
            throw IllegalArgumentException("File type '$contentType' is not allowed. Allowed: JPG, JPEG, PNG, WEBP, PDF")
        }
        val originalName = file.originalFilename?.replace("..", "") ?: "unnamed"
        val extension = originalName.substringAfterLast('.', "bin")
        val objectKey = "${UUID.randomUUID()}.$extension"

        s3.putObject(
            PutObjectRequest.builder()
                .bucket(bucket)
                .key(objectKey)
                .contentType(contentType)
                .build(),
            RequestBody.fromInputStream(file.inputStream, file.size),
        )

        return repo.save(
            FileMetadata(
                originalName = originalName,
                contentType = contentType,
                size = file.size,
                storagePath = objectKey,
                uploadedBy = auth.name,
            )
        )
    }

    fun loadFile(id: String): Pair<FileMetadata, Resource>? {
        val meta = repo.findById(id).orElse(null) ?: return null
        val response = s3.getObject(
            GetObjectRequest.builder()
                .bucket(bucket)
                .key(meta.storagePath)
                .build()
        )
        return meta to InputStreamResource(response)
    }

    fun deleteFile(id: String, auth: Authentication) {
        val meta = repo.findById(id).orElseThrow { NoSuchElementException("File not found") }
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (meta.uploadedBy != auth.name && !isSuperAdmin) throw IllegalAccessException("Not allowed")
        s3.deleteObject(
            DeleteObjectRequest.builder()
                .bucket(bucket)
                .key(meta.storagePath)
                .build()
        )
        repo.delete(meta)
    }

    fun getMetadata(id: String): FileMetadata? = repo.findById(id).orElse(null)
}
