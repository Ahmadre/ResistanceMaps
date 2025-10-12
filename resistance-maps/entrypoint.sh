#!/bin/bash -eu

echo "Building Flutter app with runtime environment variables..."
echo "API_BASE: ${API_BASE}"
echo "OIDC_ISSUER_PUBLIC: ${OIDC_ISSUER_PUBLIC}"

# Build Flutter web app with runtime environment variables
flutter build web --release \
    --web-renderer canvaskit \
    --base-href / \
    --dart-define API_BASE="${API_BASE}" \
    --dart-define OIDC_ISSUER_PUBLIC="${OIDC_ISSUER_PUBLIC}" \
    --dart-define OIDC_CLIENT_ID="${OIDC_CLIENT_ID}" \
    --dart-define OIDC_REDIRECT_URI="${OIDC_REDIRECT_URI}"

# Copy built files to nginx web directory
chmod -R 755 /usr/share/nginx/html
rm -rf /usr/share/nginx/html/* 2>/dev/null || true
cp -r /app/build/web/* /usr/share/nginx/html/

echo "Starting Nginx server..."
nginx -g "daemon off;"