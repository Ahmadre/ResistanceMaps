class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint({required this.lat, required this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class RouteModel {
  final String? id;
  final String title;
  final String? description;
  final List<GeoPoint> waypoints;
  final String visibility;
  final String? createdBy;
  final String? groupId;
  final List<String> tags;
  final String? coverImageId;
  final List<String> imageIds;
  final List<String> documentIds;
  final String? webLink;
  final DateTime? expiresAt;
  final bool hasPassword;
  final String? shareToken;
  final String? publicShareToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RouteModel({
    this.id,
    required this.title,
    this.description,
    this.waypoints = const [],
    this.visibility = 'PUBLIC',
    this.createdBy,
    this.groupId,
    this.tags = const [],
    this.coverImageId,
    this.imageIds = const [],
    this.documentIds = const [],
    this.webLink,
    this.expiresAt,
    this.hasPassword = false,
    this.shareToken,
    this.publicShareToken,
    this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String?,
      title: (json['title'] ?? '').toString(),
      description: json['description'] as String?,
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => GeoPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      visibility: (json['visibility'] ?? 'PUBLIC').toString(),
      createdBy: json['createdBy'] as String?,
      groupId: json['groupId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      coverImageId: json['coverImageId'] as String?,
      imageIds: (json['imageIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      documentIds: (json['documentIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      webLink: json['webLink'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
      hasPassword: json['passwordHash'] != null,
      shareToken: json['shareToken'] as String?,
      publicShareToken: json['publicShareToken'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}
