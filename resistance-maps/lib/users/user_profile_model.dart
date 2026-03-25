class UserProfileModel {
  final String? id;
  final String userId;
  final String username;
  final String email;
  final String? displayName;
  final bool isPublic;
  final DateTime? createdAt;

  const UserProfileModel({
    this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.displayName,
    this.isPublic = true,
    this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String?,
      userId: (json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: json['displayName'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
