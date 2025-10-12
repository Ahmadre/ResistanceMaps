import '../data/session_storage.dart';
import '../domain/session.dart';

class AuthService {
  AuthService(this.storage);
  final SessionStorage storage;

  Future<void> signInWithToken(
    String accessToken, {
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    List<String> roles = const [],
  }) async {
    final session = Session(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt,
      roles: roles,
    );
    await storage.save(session);
  }

  Session? currentSession() => storage.load();

  Future<void> signOut() => storage.clear();
}
