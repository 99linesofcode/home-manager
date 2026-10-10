---
name: docker
description: The user's Docker and Docker Compose environment contract — the three-tier docker-base ← docker-<language> ← project layout, the submodule paths (base / docker), .yaml naming, the docker-compose.yaml.dist template, Compose extends over duplication, image pinning, per-project namespacing, the devcontainer split, and the production image. Use when creating or changing a Docker or Docker Compose dev environment, adding a service to docker-base, adding or extending a language wrapper (docker-php, docker-ruby), wiring a project's compose, or defining the production image.
---

# docker

The user's container environment contract: a three-tier system of reusable
Compose environments. Docker Compose is for development; a language wrapper's
multi-stage Dockerfile is for production. Deployment of that image is the
`kubernetes` skill.

## The three tiers

| Tier | Repo | Role | Consumer adds it as |
|---|---|---|---|
| Base | `docker-base` | Shared services (meilisearch, mysql, nodejs, phpmyadmin, redis) + the Ubuntu-LTS devcontainer | `base` |
| Wrapper | `docker-php`, `docker-ruby` | A language environment: extends base, adds language services, owns the production image | `docker` |
| Project | (the app) | Consumes a wrapper; owns its own `docker-compose.yaml` | — |
| Index | `docker-collection` | Submodules the wrappers; a reference list, not an environment | — |

The submodule path **is** the contract: a base is always added as `base` (by a
wrapper), a wrapper is always added as `docker` (by a project). Every `extends`
path follows from those two names.

## Compose conventions

- **`.yaml`, never `.yml`.** The file is `docker-compose.yaml` everywhere.
- **Extend, don't duplicate.** A wrapper's `docker-compose.yaml` extends
  `./base/docker-compose.yaml`; a project's compose extends
  `./docker/docker-compose.yaml`. Compose resolves `extends.file` relative to
  the file that declares it, so the wrapper's own compose reads `./base/...`
  and the same wrapper, mounted at `./docker/`, reads `./docker/base/...` from
  the project.
- **The `.dist` template.** Every wrapper ships `docker-compose.yaml.dist` —
  the project-layout compose the consumer copies to its root as
  `docker-compose.yaml`. Optional services are commented out in the `.dist`;
  the consumer uncomments what it needs.
- **Pin every image** to an exact version. Prefer the alpine variant; when a
  service publishes no alpine tag, or its alpine variant changes the
  architecture (e.g. phpmyadmin is fpm-only), keep the default variant and say
  so.
- **Namespace per project.** Containers `${APP_NAME}-<service>`, network
  `${APP_NAME}-net`, named volumes `${APP_NAME}-vol-<name>`. `APP_NAME` is
  declared in the app's `.env`.
- **Healthcheck every service** that can take one, `CMD`-form.
- **`.env.example`** documents every variable the compose reads; the real
  `.env` is gitignored.

## The devcontainer split

`docker-base` ships the devcontainer **Dockerfile** (Ubuntu LTS + asdf/zoxide +
the shared tooling). The wrapper ships the **`devcontainer.json`** (editor,
extensions, formatter settings). The base has no `devcontainer.json` on
purpose — it is not directly usable as a devcontainer; the wrapper is.

## The production image

The wrapper owns a multi-stage `Dockerfile` for production (PHP: FrankenPHP).
Build the production target explicitly and tag it for the registry:

```
docker build --target production -t ghcr.io/99linesofcode/<image>:<tag> -f <wrapper>/Dockerfile .
```

Push to GHCR; the `kubernetes` skill deploys it.

## Monitoring

Monitoring is opt-in locally, not always-on. Applications expose metrics on a
`/metrics` endpoint in every environment — the same instrumentation runs
locally and in production, only the scrape config differs. The base ships a
commented `observability` block in the `.dist` (cAdvisor + node-exporter +
Prometheus + Grafana) so a project can enable container and host metrics
without paying the cost by default; Netdata is the documented one-container
fallback. The stack is being finalized (see the `kubernetes-monitoring` plan).

## Procedure

**Add a service to the base** — define it once in
`docker-base/docker-compose.yaml`, pin the image, add a healthcheck. Wrappers
and projects inherit it.

**Add a language wrapper** — create `docker-<language>` from `git-skeleton`
(see `new-project`), add `docker-base` as the `base` submodule, write
`docker-compose.yaml` (extends `./base/...`) and `docker-compose.yaml.dist`
(project layout), add `devcontainer.json` and the production Dockerfile, then
add it to `docker-collection`.

**Consume a wrapper in a project** — `git submodule add <wrapper> docker`,
copy `docker/docker-compose.yaml.dist` to `./docker-compose.yaml`, set
`APP_NAME` and the variables from `docker/.env.example` in `.env`, then
`docker compose up -d`.

## Gotchas

- The `.dist` extends `./docker/docker-compose.yaml`, **not** `./base/...` —
  a project does not see base directly; the wrapper does.
- A wrapper's own compose extends `./base/...`; do not write it in
  project layout — that is what the `.dist` is for.
- `depends_on` is not readiness; when order matters use `healthcheck` plus
  `depends_on: { condition: service_healthy }`.
- Never commit a real `.env` (see `server01` for the anti-pattern).

## Revisit trigger

The Docker story is expected to be redefined when the stack moves fully onto
Kubernetes; treat this contract as current until then.

## Related

- **References:** `kubernetes` (the production deployment target),
  `new-project` (scaffolding a wrapper), `git-workflow` (submodules).
