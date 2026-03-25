class GroupModel {
  final String? id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime? createdAt;

  const GroupModel({
    this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String?,
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

enum GroupRole { owner, admin, member }

GroupRole groupRoleFromString(String value) {
  switch (value.toUpperCase()) {
    case 'OWNER':
      return GroupRole.owner;
    case 'ADMIN':
      return GroupRole.admin;
    default:
      return GroupRole.member;
  }
}

String groupRoleToString(GroupRole role) {
  switch (role) {
    case GroupRole.owner:
      return 'OWNER';
    case GroupRole.admin:
      return 'ADMIN';
    case GroupRole.member:
      return 'MEMBER';
  }
}

class GroupMemberModel {
  final String? id;
  final String groupId;
  final String userId;
  final GroupRole role;
  final DateTime? joinedAt;

  const GroupMemberModel({
    this.id,
    required this.groupId,
    required this.userId,
    this.role = GroupRole.member,
    this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String?,
      groupId: (json['groupId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      role: groupRoleFromString((json['role'] ?? 'MEMBER').toString()),
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'].toString()) : null,
    );
  }
}
