class MapListModel {
  final String? id;
  final String title;
  final String? description;
  final String visibility;
  final String? createdBy;
  final String? groupId;
  final List<String> markerIds;
  final List<String> routeIds;
  final DateTime? expiresAt;
  final bool hasPassword;
  final String? shareToken;
  final String? publicShareToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MapListModel({
    this.id,
    required this.title,
    this.description,
    this.visibility = 'PUBLIC',
    this.createdBy,
    this.groupId,
    this.markerIds = const [],
    this.routeIds = const [],
    this.expiresAt,
    this.hasPassword = false,
    this.shareToken,
    this.publicShareToken,
    this.createdAt,
    this.updatedAt,
  });

  factory MapListModel.fromJson(Map<String, dynamic> json) {
    return MapListModel(
      id: json['id'] as String?,
      title: (json['title'] ?? '').toString(),
      description: json['description'] as String?,
      visibility: (json['visibility'] ?? 'PUBLIC').toString(),
      createdBy: json['createdBy'] as String?,
      groupId: json['groupId'] as String?,
      markerIds: (json['markerIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      routeIds: (json['routeIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      hasPassword: json['passwordHash'] != null,
      shareToken: json['shareToken'] as String?,
      publicShareToken: json['publicShareToken'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}
