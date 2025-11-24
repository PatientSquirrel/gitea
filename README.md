# Gitea + Keycloak SSO (ohne externe Datenbank)

Dieses Projekt startet eine lokale Umgebung mit:

- Gitea (mit SQLite)
- Keycloak (mit eingebauter H2-Datenbank, `start-dev` – nur für Entwicklung!)

## Start

```bash
docker compose up -d
```

- Gitea: http://localhost:3000
- Keycloak: http://localhost:8080

Standard-Admin für Keycloak:

- Benutzer: `admin`
- Passwort: `admin`

## Keycloak konfigurieren (Realm & Client)

1. In Keycloak einloggen (`http://localhost:8080` → "Administration Console").
2. Neuen Realm anlegen, z.B. `gitea`.
3. Unter **Clients** neuen Client anlegen, z.B. `gitea`:
   - Client type: `OpenID Connect`
   - Client ID: `gitea`
   - Root URL: `http://localhost:3000/`
   - Valid redirect URIs: `http://localhost:3000/user/oauth2/keycloak/callback`
   - Web origins: `http://localhost:3000`
4. Client speichern und den **Client Secret** merken.

## Gitea als OAuth2 / OpenID-Client für Keycloak einrichten

1. In Gitea als Admin einloggen (`http://localhost:3000`).
2. Zu **Site Administration → Authentication Sources**.
3. **Add Authentication Source** → Typ: `OAuth2` (oder OpenID Connect, je nach Version).
4. Werte setzen (Beispiel):
   - Name: `Keycloak`
   - Provider: `OpenID Connect`
   - Client ID: `gitea`
   - Client Secret: `<Client-Secret aus Keycloak>`
   - OpenID Connect Auto Discovery URL:
     - `http://keycloak:8080/realms/gitea/.well-known/openid-configuration`
   - Scopes: `openid profile email`
   - Map user name / email nach Bedarf.
5. Speichern.

Danach solltest du dich bei Gitea über den Keycloak-Login anmelden können.

## Hinweis

- Diese Umgebung ist **nur** für lokale Entwicklung gedacht (H2 & SQLite, Standard-Passwörter).
- Für Produktion solltest du eine externe Datenbank (z.B. Postgres) für Keycloak und Gitea einrichten und sichere Passwörter/SSL verwenden.
