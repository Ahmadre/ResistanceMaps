import 'package:hive_flutter/hive_flutter.dart';
import '../domain/session.dart';

class SessionStorage {
  static const _boxName = 'app';

  Future<void> init() async {
    // Register Session adapter (typeId = 1) once
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SessionAdapter());
    }
  }

  Future<void> save(Session session) async {
    final box = Hive.box(_boxName);
    await box.put('session', session);
  }

  Session? load() {
    final box = Hive.box(_boxName);
    return box.get('session') as Session?;
  }

  Future<void> clear() async {
    final box = Hive.box(_boxName);
    await box.delete('session');
  }

  Future<void> saveCurrentWith({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    List<String> roles = const [],
  }) async {
    final current = load();
    final updated = Session(
      accessToken: accessToken,
      refreshToken: refreshToken ?? current?.refreshToken,
      idToken: idToken ?? current?.idToken,
      expiresAt: expiresAt ?? current?.expiresAt,
      roles: roles.isNotEmpty ? roles : (current?.roles ?? const []),
    );
    await save(updated);
  }
}
