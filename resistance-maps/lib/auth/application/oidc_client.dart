import 'dart:async';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../core/env.dart';
import '../../core/platform_origin_stub.dart'
    if (dart.library.html) '../../core/platform_origin_web.dart';
import 'package:dio/dio.dart';

class OidcClientConfig {
  final String issuer; // e.g. http://localhost:8081/realms/resistance
  final String clientId; // e.g. resistance-mobile
  final String
  redirectUri; // e.g. com.resistance.app://callback or http://localhost:port/callback for web
  final List<String> scopes;
  const OidcClientConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    this.scopes = const ['openid', 'profile', 'email'],
  });
}

class OidcAuthResult {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? expiresAt;
  final List<String> roles;
  const OidcAuthResult({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    this.roles = const [],
  });
}

class OidcClientWrapper {
  final OidcClientConfig cfg;
  OidcClientWrapper(this.cfg);

  factory OidcClientWrapper.fromEnv() {
    final origin = webOrigin();
    final autoWebRedirect = origin != null ? '$origin/callback' : null;
    final redirect = Env.oidcRedirectUri.isNotEmpty
        ? Env.oidcRedirectUri
        : (autoWebRedirect ?? Env.oidcRedirectUri);
    return OidcClientWrapper(
      OidcClientConfig(
        issuer: Env.oidcIssuerPublic,
        clientId: Env.oidcClientId,
        redirectUri: redirect,
      ),
    );
  }

  Future<OidcAuthResult> signIn() async {
    final authEndpoint = Uri.parse(
      '${cfg.issuer}/protocol/openid-connect/auth',
    );
    final tokenEndpoint = Uri.parse(
      '${cfg.issuer}/protocol/openid-connect/token',
    );

    final client = OAuth2Client(
      authorizeUrl: authEndpoint.toString(),
      tokenUrl: tokenEndpoint.toString(),
      redirectUri: cfg.redirectUri,
      customUriScheme: Uri.parse(cfg.redirectUri).scheme,
    );

    final helper = OAuth2Helper(
      client,
      clientId: cfg.clientId,
      scopes: cfg.scopes,
      enablePKCE: true,
      // oauth2_client will use a suitable WebAuth implementation per platform.
    );

    final token = await helper.getToken();
    final access = token?.accessToken ?? '';
    final refresh = token?.refreshToken;
    final expiresAt = token?.expirationDate;
    final roles = _extractRolesFromAccess(access);
    return OidcAuthResult(
      accessToken: access,
      refreshToken: refresh,
      idToken: null,
      expiresAt: expiresAt,
      roles: roles,
    );
  }

  /// Completes sign-in after the browser was redirected back from the IdP.
  ///
  /// For oauth2_client, calling `getToken()` again will resume the pending
  /// PKCE/code exchange if there is one (on Web) and return the token.
  /// If there's nothing to resume, it will fetch using existing session info.
  Future<OidcAuthResult?> completeFromRedirect() async {
    try {
      final authEndpoint = Uri.parse(
        '${cfg.issuer}/protocol/openid-connect/auth',
      );
      final tokenEndpoint = Uri.parse(
        '${cfg.issuer}/protocol/openid-connect/token',
      );

      final client = OAuth2Client(
        authorizeUrl: authEndpoint.toString(),
        tokenUrl: tokenEndpoint.toString(),
        redirectUri: cfg.redirectUri,
        customUriScheme: Uri.parse(cfg.redirectUri).scheme,
      );

      final helper = OAuth2Helper(
        client,
        clientId: cfg.clientId,
        scopes: cfg.scopes,
        enablePKCE: true,
      );

      final token = await helper.getToken();
      final access = token?.accessToken ?? '';
      if (access.isEmpty) return null;
      final refresh = token?.refreshToken;
      final expiresAt = token?.expirationDate;
      final roles = _extractRolesFromAccess(access);
      return OidcAuthResult(
        accessToken: access,
        refreshToken: refresh,
        idToken: null,
        expiresAt: expiresAt,
        roles: roles,
      );
    } catch (_) {
      return null;
    }
  }

  Future<OidcAuthResult?> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) return null;
    final tokenEndpoint = Uri.parse(
      '${cfg.issuer}/protocol/openid-connect/token',
    );
    final dio = Dio(
      BaseOptions(contentType: Headers.formUrlEncodedContentType),
    );
    final res = await dio.post(
      tokenEndpoint.toString(),
      data: {
        'grant_type': 'refresh_token',
        'client_id': cfg.clientId,
        'refresh_token': refreshToken,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final access = data['access_token'] as String?;
    if (access == null || access.isEmpty) return null;
    final idToken = data['id_token'] as String?;
    final refreshOut = data['refresh_token'] as String? ?? refreshToken;
    final expiresIn = (data['expires_in'] as num?)?.toInt();
    final expiresAt = expiresIn != null
        ? DateTime.now().add(Duration(seconds: expiresIn))
        : null;
    final roles = _extractRolesFromAccess(access);
    return OidcAuthResult(
      accessToken: access,
      refreshToken: refreshOut,
      idToken: idToken,
      expiresAt: expiresAt,
      roles: roles,
    );
  }

  List<String> _extractRolesFromAccess(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) return const [];
    try {
      final payload = Jwt.parseJwt(accessToken);
      final ra = payload['realm_access'] as Map<String, dynamic>?;
      final list = (ra?['roles'] as List?)?.cast<String>() ?? [];
      return list;
    } catch (_) {
      return const [];
    }
  }
}
