package dev.resistance.maps.file

import org.springframework.beans.factory.annotation.Value
import org.springframework.core.io.Resource
import org.springframework.core.io.UrlResource
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import java.util.*

@Service
class FileStorageService(
    private val repo: FileMetadataRepository,
    @Value("\${app.storage.upload-dir:./uploads}") uploadDir: String,
) {
    private val rootPath: Path = Paths.get(uploadDir).toAbsolutePath().normalize()

    companion object {
        val ALLOWED_IMAGE_TYPES = setOf("image/jpeg", "image/png", "image/webp")
        val ALLOWED_DOCUMENT_TYPES = setOf("application/pdf")
        val ALLOWED_TYPES = ALLOWED_IMAGE_TYPES + ALLOWED_DOCUMENT_TYPES
        const val MAX_IMAGES = 10
    }

    init {
        Files.createDirectories(rootPath)
    }

    fun storeFile(file: MultipartFile, auth: Authentication): FileMetadata {
        val contentType = file.contentType ?: throw IllegalArgumentException("Content type is required")
        if (contentType !in ALLOWED_TYPES) {
            throw IllegalArgumentException("File type '$contentType' is not allowed. Allowed: JPG, JPEG, PNG, WEBP, PDF")
        }
        val originalName = file.originalFilename?.replace("..", "") ?: "unnamed"
        val extension = originalName.substringAfterLast('.', "bin")
        val storedName = "${UUID.randomUUID()}.$extension"
        val targetPath = rootPath.resolve(storedName).normalize()

        if (!targetPath.startsWith(rootPath)) {
            throw IllegalArgumentException("Invalid file path")
        }

        Files.copy(file.inputStream, targetPath, StandardCopyOption.REPLACE_EXISTING)

        return repo.save(
            FileMetadata(
                originalName = originalName,
                contentType = contentType,
                size = file.size,
                storagePath = storedName,
                uploadedBy = auth.name,
            )
        )
    }

    fun loadFile(id: String): Pair<FileMetadata, Resource>? {
        val meta = repo.findById(id).orElse(null) ?: return null
        val filePath = rootPath.resolve(meta.storagePath).normalize()
        if (!filePath.startsWith(rootPath)) return null
        val resource = UrlResource(filePath.toUri())
        return if (resource.exists() && resource.isReadable) meta to resource else null
    }

    fun deleteFile(id: String, auth: Authentication) {
        val meta = repo.findById(id).orElseThrow { NoSuchElementException("File not found") }
        val isSuperAdmin = auth.authorities.any { it.authority == "ROLE_SUPERADMIN" }
        if (meta.uploadedBy != auth.name && !isSuperAdmin) throw IllegalAccessException("Not allowed")
        val filePath = rootPath.resolve(meta.storagePath).normalize()
        if (filePath.startsWith(rootPath)) {
            Files.deleteIfExists(filePath)
        }
        repo.delete(meta)
    }

    fun getMetadata(id: String): FileMetadata? = repo.findById(id).orElse(null)
}
