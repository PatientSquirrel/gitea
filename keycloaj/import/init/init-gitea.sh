#!/bin/sh
set -e

GITEA_URL="http://gitea:3000"
KC_DISCOVERY="http://keycloak:8080/realms/gitea/.well-known/openid-configuration"
CLIENT_ID="gitea"
CLIENT_SECRET="gitea-keycloak-secret"
AUTH_NAME="Keycloak"

ADMIN_USER="${GITEA_ADMIN_USERNAME:-admin}"
ADMIN_PASS="${GITEA_ADMIN_PASSWORD:-admin123}"
ADMIN_MAIL="${GITEA_ADMIN_EMAIL:-admin@example.com}"

# Warten bis Gitea HTTP erreichbar ist
echo "[gitea-init] Waiting for Gitea at $GITEA_URL ..."
while ! wget -q --spider "$GITEA_URL"; do
  sleep 3
done

echo "[gitea-init] Gitea is up, configuring OAuth source..."

GITEA_BIN="/usr/local/bin/gitea"
APP_INI="/data/gitea/conf/app.ini"

# Admin-User sicherstellen
if ! $GITEA_BIN --config "$APP_INI" admin user list --admin | grep -qi "^$ADMIN_USER"; then
  echo "[gitea-init] Creating admin user '$ADMIN_USER' ..."
  $GITEA_BIN --config "$APP_INI" admin user create \
    --admin \
    --username "$ADMIN_USER" \
    --password "$ADMIN_PASS" \
    --email "$ADMIN_MAIL" || echo "[gitea-init] Admin user creation may have failed or already exists."
else
  echo "[gitea-init] Admin user '$ADMIN_USER' already exists."
fi

# Prüfen, ob Auth-Source bereits existiert
if $GITEA_BIN --config "$APP_INI" admin auth list | grep -qi "$AUTH_NAME"; then
  echo "[gitea-init] Auth source '$AUTH_NAME' already exists, nothing to do."
  exit 0
fi

# OAuth/OpenID-Quelle anlegen
$GITEA_BIN --config "$APP_INI" admin auth add-oauth \
  --name "$AUTH_NAME" \
  --provider openidConnect \
  --key "$CLIENT_ID" \
  --secret "$CLIENT_SECRET" \
  --auto-discover-url "$KC_DISCOVERY" \
  --scopes "openid profile email"

echo "[gitea-init] Auth source '$AUTH_NAME' created successfully."
