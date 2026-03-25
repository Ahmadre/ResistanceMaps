class FileMetadataModel {
  final String? id;
  final String originalName;
  final String contentType;
  final int size;
  final String storagePath;
  final String uploadedBy;
  final DateTime? createdAt;

  const FileMetadataModel({
    this.id,
    required this.originalName,
    required this.contentType,
    required this.size,
    required this.storagePath,
    required this.uploadedBy,
    this.createdAt,
  });

  factory FileMetadataModel.fromJson(Map<String, dynamic> json) {
    return FileMetadataModel(
      id: json['id'] as String?,
      originalName: (json['originalName'] ?? '').toString(),
      contentType: (json['contentType'] ?? '').toString(),
      size: (json['size'] as num?)?.toInt() ?? 0,
      storagePath: (json['storagePath'] ?? '').toString(),
      uploadedBy: (json['uploadedBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isImage => const {'image/jpeg', 'image/png', 'image/webp'}.contains(contentType);
}
