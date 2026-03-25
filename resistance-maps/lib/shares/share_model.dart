enum ResourceType { marker, route, list }

String resourceTypeToString(ResourceType type) {
  switch (type) {
    case ResourceType.marker:
      return 'MARKER';
    case ResourceType.route:
      return 'ROUTE';
    case ResourceType.list:
      return 'LIST';
  }
}

ResourceType resourceTypeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'ROUTE':
      return ResourceType.route;
    case 'LIST':
      return ResourceType.list;
    default:
      return ResourceType.marker;
  }
}

class ShareModel {
  final String? id;
  final ResourceType resourceType;
  final String resourceId;
  final String? sharedWithUserId;
  final String? sharedWithGroupId;
  final DateTime? expiresAt;
  final String createdBy;
  final DateTime? createdAt;

  const ShareModel({
    this.id,
    required this.resourceType,
    required this.resourceId,
    this.sharedWithUserId,
    this.sharedWithGroupId,
    this.expiresAt,
    required this.createdBy,
    this.createdAt,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] as String?,
      resourceType: resourceTypeFromString((json['resourceType'] ?? 'MARKER').toString()),
      resourceId: (json['resourceId'] ?? '').toString(),
      sharedWithUserId: json['sharedWithUserId'] as String?,
      sharedWithGroupId: json['sharedWithGroupId'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
