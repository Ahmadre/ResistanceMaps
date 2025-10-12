# ResistanceMaps Backend & Local Stack

This repository includes a Kotlin/Spring Boot backend plus a local Docker stack for development.

Components:

- Spring Boot 3 (Resource Server) with MongoDB and RabbitMQ
- MongoDB ReplicaSet (3 nodes) suitable for local development
- RabbitMQ (management UI on :15672)
- Keycloak (realm `resistance`) to act as IdP

## Quick start

1) Copy environment file

```bash
cp infra/.env.example infra/.env
```

1) Start the stack

```bash
cd infra
docker compose up --build
```

- Backend API: <http://localhost:8080>
- Keycloak: <http://localhost:8081> (admin/admin)
- RabbitMQ: <http://localhost:15672> (guest/guest)
- Mongo: ReplicaSet URI `mongodb://mongo1:27017,mongo2:27018,mongo3:27019/resistance?replicaSet=rs0`

1) Test API

```bash
curl http://localhost:8080/api/markers/public
```

Secured endpoints require an access token issued by Keycloak (client `resistance-mobile` with PKCE or service account of `resistance-api`).

## Application configuration

Backend reads the following env vars (see `backend/src/main/resources/application.yml`):

- PORT (default 8080)
- MONGODB_URI
- RABBITMQ_HOST/PORT/USER/PASSWORD
- OIDC_ISSUER_URI (Keycloak issuer)

## Flutter App environment

Expose the backend base URL and issuer for the app at startup (via Docker or env):

- `FLUTTER_API_BASE=http://localhost:8080`
- `OIDC_ISSUER_PUBLIC=http://localhost:8081/realms/resistance`

## Security notes

- Spring Security configured as OAuth2 Resource Server (JWT) with Keycloak issuer
- CORS wildcard for local development; restrict in production
- Prefer putting an API Gateway/WAF in front for rate limiting and TLS termination
- No secrets checked into VCS; use real secret store in production (Vault/SM)

## Keycloak

The realm `resistance` is imported at startup from `infra/keycloak/realms/resistance-realm.json` and provides realm roles:

- USER, INTERN, ADMIN, SUPERADMIN

Clients:

- `resistance-mobile` (public, PKCE)
- `resistance-api` (confidential, service accounts)

## RabbitMQ

A sample exchange/queue is configured (`heavy.exchange` / `heavy.queue`). Use `HeavyTaskPublisher` to dispatch heavy jobs.

## Mongo ReplicaSet

Three containers `mongo1`, `mongo2`, `mongo3` with ports 27017/27018/27019. An init job `mongo-setup` runs `scripts/mongo-init.sh` to initiate the replicaset.

## Development

Run backend locally without Docker:

- Ensure MongoDB RS and RabbitMQ are reachable
- Export environment variables (see `.env.example`)
- From `backend/` run: `./gradlew bootRun` (or use the Dockerfile to build)

## Production considerations

- Put a reverse proxy / API Gateway in front (TLS+WAF)
- Harden CORS and security headers
- Use managed Keycloak or other IdP
- Use opaque tokens + introspection if immediate revocation is required
- Externalize secrets to Vault

