import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../application/auth_bloc.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  Map<String, dynamic> _decode(String token) {
    try {
      return Jwt.parseJwt(token);
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final session = state.session;
    final payload = session != null
        ? _decode(session.accessToken)
        : const <String, dynamic>{};
    final username =
        payload['preferred_username'] ??
        payload['email'] ??
        payload['name'] ??
        '-';
    final roles =
        (payload['realm_access']?['roles'] as List?)?.cast<String>() ??
        const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benutzer: $username',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Rollen: ${roles.join(', ')}'),
            const SizedBox(height: 8),
            Text('Token läuft ab: ${session?.expiresAt?.toLocal()}'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Hier kannst du künftig Profilangaben ändern (Platzhalter).',
            ),
          ],
        ),
      ),
    );
  }
}
