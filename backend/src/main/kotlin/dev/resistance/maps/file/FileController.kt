package dev.resistance.maps.file

import org.springframework.core.io.Resource
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/api/files")
class FileController(private val service: FileStorageService) {

    @PostMapping("/upload")
    @PreAuthorize("isAuthenticated()")
    fun upload(@RequestParam("file") file: MultipartFile, auth: Authentication): FileMetadata =
        service.storeFile(file, auth)

    @GetMapping("/{id}")
    fun download(@PathVariable id: String): ResponseEntity<Resource> {
        val (meta, resource) = service.loadFile(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok()
            .contentType(MediaType.parseMediaType(meta.contentType))
            .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"${meta.originalName}\"")
            .body(resource)
    }

    @GetMapping("/{id}/meta")
    fun metadata(@PathVariable id: String): ResponseEntity<FileMetadata> =
        service.getMetadata(id)?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    fun delete(@PathVariable id: String, auth: Authentication): ResponseEntity<Void> {
        service.deleteFile(id, auth)
        return ResponseEntity.noContent().build()
    }
}
