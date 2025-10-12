import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 1)
class Session {
  @HiveField(0)
  final String accessToken;
  @HiveField(1)
  final String? refreshToken;
  @HiveField(2)
  final String? idToken;
  @HiveField(3)
  final DateTime? expiresAt;
  @HiveField(4)
  final List<String> roles;

  const Session({required this.accessToken, this.refreshToken, this.idToken, this.expiresAt, this.roles = const []});
}
