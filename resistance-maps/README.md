# Resistance Maps – Flutter App

Dark-themed Flutter app with OIDC (PKCE), Routemaster routing, BLoC, Dio, Hive persistence, i18next, and flutter_map.

## Config via --dart-define

Provide these at build/run time. Defaults are sensible for local dev where possible:

- API_BASE: Base URL for backend API. Default: <http://localhost:8080>
- OIDC_ISSUER_PUBLIC: Public OIDC issuer base URL (Keycloak Realm URL), for example: <http://localhost:8081/realms/resistance>
- OIDC_CLIENT_ID: Public client ID. Default: resistance-mobile
- OIDC_REDIRECT_URI: Platform redirect URI. Default: resistance.maps://callback

Example run (web):

```bash
flutter run -d chrome \
  --dart-define=API_BASE=http://localhost:8080 \
  --dart-define=OIDC_ISSUER_PUBLIC=http://localhost:8081/realms/resistance \
  --dart-define=OIDC_CLIENT_ID=resistance-mobile \
  --dart-define=OIDC_REDIRECT_URI=http://localhost:7357/callback
```

## Redirect URIs per Plattform

Recommended URIs and setup:

- Web (Chrome/Edge/Firefox): <http://localhost:7357/callback> (update port to your dev server)
- Android: resistance.maps://callback
- iOS: resistance.maps://callback

Keycloak client (resistance-mobile, public PKCE) must include these in Valid Redirect URIs:

- <http://localhost:7357/*>
- <http://localhost:*/callback>
- resistance.maps://callback

Also set Web Origins: + and/or explicit <http://localhost:7357>

### Android

Add an intent-filter in android/app/src/main/AndroidManifest.xml (APPLICATION_ID placeholder shown):

```xml
<activity android:name="io.flutter.embedding.android.FlutterActivity" ...>
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="resistance.maps" android:host="callback" />
  </intent-filter>
</activity>
```

### iOS

Add URL Types in ios/Runner/Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>resistance.maps</string>
    </array>
  </dict>
</array>
```

### Web

Ensure the OIDC_REDIRECT_URI matches the served URL path. For local run with `flutter run -d chrome`, prefer <http://localhost:7357/callback>.

## Auth & Guards

- AuthBloc manages session (access/refresh, roles). Tokens are stored in Hive.
- A Dio AuthInterceptor injects Authorization and auto-refreshes on 401 using refresh_token.
- The /admin route is guarded and only accessible for roles ADMIN or SUPERADMIN.

## Dev Notes

- Routing: Routemaster with path URL strategy.
- Map: flutter_map with OSM tiles.
- i18n: i18next with assets/i18n (de_DE, en_GB).

