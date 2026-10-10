---
name: kubernetes
description: The user's Kubernetes contract — k3s for local and production, Helm umbrella charts, Flux GitOps, the one-chart-two-overlays local/production parity rule, GHCR for charts and images, SOPS+age secrets, cert-manager TLS, the Gateway API + Traefik ingress, and Task's constrained bootstrap role. Use when deploying to Kubernetes, writing or changing a Helm chart, wiring Flux, handling cluster secrets, or when the user references k3s, Helm, Flux, cert-manager, GHCR, chart submodules, or the kubernetes-base / kubernetes-php / kubernetes-fleet repos.
---

# kubernetes

The user's Kubernetes contract. The Docker Compose dev environment is the
`docker` skill; this skill covers everything from the production image onward —
charts, GitOps, secrets, TLS, and the local cluster.

## The repos

| Repo | Role |
|---|---|
| `kubernetes-base` | Generic reusable charts (Gateway/Traefik, cert-manager issuers). No application vocabulary. |
| `kubernetes-php` | The Laravel composition: the `laravel-stack` umbrella chart + the `frankenphp` app subchart. |
| `kubernetes-fleet` | The Flux GitOps fleet: HelmRepositories, HelmReleases, SOPS-encrypted secrets. Cluster state, not a chart. |

A chart in `kubernetes-base` never names an application; application
composition lives in the language repo (`kubernetes-php`).

## The tiers and GitOps

Three tiers, composed by Flux:

| Tier | Artefact | Lives in |
|---|---|---|
| Base | generic building-block charts | `kubernetes-base` |
| Wrapper | the app chart (`laravel-stack`) | `kubernetes-php`, published to OCI |
| Project | a HelmRelease per app + environment | `kubernetes-fleet` |

The fleet is the source of truth for cluster state: a root Kustomization
includes the HelmRepositories (`ghcr-charts` OCI + bitnami) and one HelmRelease
per app/environment. A project's deployment **is** its HelmRelease — the chart
is consumed by OCI version through the HelmRepository, **never** pulled into
the project as a git submodule. Flux reconciles; after bootstrap nothing is
applied by hand.

Keep it lean. The umbrella stays self-contained — it vendors its external
dependencies as tarballs for reproducible builds, which is a build detail, not
the consumption mechanism. Extract a chart into `kubernetes-base` only when a
second stack actually duplicates it: a normal chart at two stacks, a `common`
library chart when several charts share template logic. Do not build the
base/wrapper split ahead of need.

## The environments — and the parity rule

Local is **k3s on the workstation** (`nixos-config/modules/k3s.nix`): the
bundled Traefik disabled (`--disable=traefik`), the Docker runtime
(`--docker`), node IP `10.0.0.1`, and a dnsmasq wildcard sending `*.test` to
the cluster. Production is a Flux-managed k3s cluster. Both are reconciled from
the same fleet repo.

**Local and production run the same chart.** They differ only in a values
overlay — never in template branching. There is no
`{{ if eq .Values.global.environment "local" }}` anywhere in a chart;
environment differences are values toggles. The `laravel-stack` chart is
released twice in the fleet (`laravel-skeleton` local,
`laravel-skeleton-production` production): same image, same services, same
routes — different values.

| Concern | Local | Production |
|---|---|---|
| Domain | `*.99linesofcode.test` | `*.99linesofcode.nl` |
| TLS issuer | self-signed → local CA | Let's Encrypt via Cloudflare DNS-01 |
| Persistence | off | on (sized PVCs) |
| App code | `hostPath` mount of the source tree | baked into the image |
| Secrets | decrypted + applied directly | Flux decrypts in-cluster |

## Charts

- **An umbrella chart composes subcharts.** `laravel-stack` depends on
  Traefik, cert-manager, PostgreSQL, Redis (Bitnami), and the local
  `frankenphp` subchart. Optional dependencies carry `condition: <chart>.enabled`.
- **Values layer, don't branch.** `values.yaml` holds shared defaults;
  `values.local.yaml` / `values.production.yaml` hold the per-environment
  overlay; the fleet HelmRelease adds the final layer. Templates stay
  environment-agnostic.
- **Vendor the tarballs.** `helm dependency build` writes `charts/*.tgz`;
  commit them so builds are reproducible and offline. `Chart.lock` pins them.
- **Name resources `<release>-<chart>-<kind>`** so multiple releases coexist.

## TLS

cert-manager issues every certificate. Local uses a two-step self-signed chain
(a `self-signed-issuer` bootstraps a CA `Certificate`, whose secret backs a
`local-ca-issuer`); production uses an ACME `ClusterIssuer` with the Cloudflare
DNS-01 solver. The three issuer templates are gated by `issuers.*.enabled`
toggles so only the enabled ones render. A single `Certificate` requests
`global.domain` from the issuer named in `global.issuer.name`.

## Secrets — SOPS + age

Secrets never sit in git as plaintext.

1. Write a Kubernetes `Secret` manifest with real values under
   `secrets/<environment>/`.
2. Encrypt it in place with SOPS; `.sops.yaml` maps each path to an age
   recipient. **Each environment has its own key** — production secrets cannot
   be decrypted with the local key.
3. Flux's kustomize-controller decrypts in-cluster from the `sops-age-key`
   Secret in `flux-system` (created out-of-band, never committed).
4. Charts reference the decrypted Secret with `existingSecret` (Bitnami) or
   `secretKeyRef` (app env vars) — never a value in `values.yaml`.
5. The HelmRelease carries `dependsOn: sops-secrets` so the secrets exist
   first.

Local dev has no Flux: `sops --decrypt secrets/local/secrets.yaml | kubectl
apply -f -`.

## Registry — GHCR

Charts and images both live on GHCR. Charts are OCI artifacts
(`oci://ghcr.io/99linesofcode/charts/<name>`); Flux pulls them through a
`HelmRepository` (`type: oci`) with a `github-credentials` secretRef. Images
are `ghcr.io/99linesofcode/<image>`. Publishing a chart is `helm package` +
`helm push ... oci://ghcr.io/99linesofcode/charts` in CI on a version tag.

## Monitoring

Monitoring is part of the stack, not an afterthought, and it follows the parity
rule: the same stack locally and in production, differing only in values
(retention, persistence, alerting). The direction is a Prometheus-compatible
stack — `kube-prometheus-stack` (Prometheus Operator, Prometheus, Alertmanager,
Grafana, node-exporter, kube-state-metrics) — composed as a generic `monitoring`
chart in `kubernetes-base` and released by Flux in a `monitoring` namespace.
Applications expose `/metrics`; a `ServiceMonitor` scrapes them. A lighter
alternative (VictoriaMetrics) is under consideration. The concrete choice is
tracked in the `kubernetes-monitoring` plan.

## Task — constrained

Task (go-task) covers only what GitOps cannot:

- **`bootstrap:*` in `kubernetes-fleet`** — the one-time cluster bring-up:
  install the Gateway API CRDs (the chart assumes they exist), `flux bootstrap`,
  create the `sops-age-key` and `github-credentials` secrets.
- **`chart:*` / `local:*` in the chart repos** — lint, template, package, push;
  build and load an image into k3s; port-forward; logs.

Everything steady-state is declarative — Flux reconciles; there is no
day-to-day `kubectl apply`. Tasks stay thin, idempotent wrappers with no logic.

## Gotchas

- The Gateway API CRDs are **not** in the chart — install them before the
  chart or the Gateway never programs.
- cert-manager's CRDs come from its subchart (`installCRDs: true`).
- The `sops-age-key` and `github-credentials` secrets are created out-of-band;
  they are in no manifest.
- k3s ships Traefik; the chart installs its own in Gateway API mode — disable
  the bundled one.

## Related

- **References:** `docker` (the dev environment and the production image),
  `git-workflow` (fleet commits), `new-project` (new chart repos).
