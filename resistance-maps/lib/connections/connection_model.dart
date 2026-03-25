enum ConnectionStatus { pending, accepted, rejected }

ConnectionStatus connectionStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'ACCEPTED':
      return ConnectionStatus.accepted;
    case 'REJECTED':
      return ConnectionStatus.rejected;
    default:
      return ConnectionStatus.pending;
  }
}

class ConnectionModel {
  final String? id;
  final String requesterId;
  final String targetId;
  final ConnectionStatus status;
  final DateTime? createdAt;

  const ConnectionModel({
    this.id,
    required this.requesterId,
    required this.targetId,
    this.status = ConnectionStatus.pending,
    this.createdAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String?,
      requesterId: (json['requesterId'] ?? '').toString(),
      targetId: (json['targetId'] ?? '').toString(),
      status: connectionStatusFromString((json['status'] ?? 'PENDING').toString()),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
