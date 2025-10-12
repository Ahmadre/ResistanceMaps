class Env {
  // All values are expected to be provided via --dart-define
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8080',
  );
  static const oidcIssuerPublic = String.fromEnvironment(
    'OIDC_ISSUER_PUBLIC',
    defaultValue: '',
  );
  static const oidcClientId = String.fromEnvironment(
    'OIDC_CLIENT_ID',
    defaultValue: 'resistance-mobile',
  );
  static const oidcRedirectUri = String.fromEnvironment(
    'OIDC_REDIRECT_URI',
    defaultValue: 'http://localhost:7357/callback',
  );
}
