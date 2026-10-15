---
name: skill-loading
description: How the orchestrator resolves a task to a skill set and loads it — the three layers (descriptions trigger, the routing matrix routes, `## Related` navigates), the library-wide routing matrix, the `Loads` closure, and fail-closed activation. Use when resolving which skills govern a task, reading or changing the routing matrix, or composing a worker's governing set.
metadata:
  category: tooling
  route-when: "Use when resolving which skills govern a task, reading or changing the routing matrix, or composing a worker's governing set."
  route-not-when: "Use `skill-authoring` to write or change a skill, and `agent-delegation` to compose the rest of a worker package."
---

# skill-loading

The contract for navigating the library: how a task becomes a set of skills, and
how that set is loaded. It applies to every task, not only software development.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `skill-authoring` (how a skill is written, and the `## Related`
  conventions), `agent-delegation` (the rest of a worker package), `jev-gates`
  (the classification calls that resolve a row).

## External

| Path | Load | Read when |
|---|---|---|
| `~/Documents/Obsidian/AI/wiki/syntheses/skill-architecture.md` | on-demand | for the rationale behind the three layers and the deferred scale machinery |

## The three layers

1. **Descriptions trigger.** Every skill's `description` is read at session
   start — that is the discovery surface. A task that routed wrong means a
   description and/or a row defect.
2. **The matrix routes.** The routing matrix below is the single authoritative
   lookup: one row per skill — its `route-when` sentence — and the skills it
   `Loads`.
3. **`## Related` navigates.** Cross-references stay in each skill's Related
   (`Loads` = required companions, `References` = on-demand). Navigation, not
   routing.

## The routing matrix

<!-- generated:start — do not edit; regenerate with build-catalog.mjs -->
| Task | Governing skills |
|---|---|
| Use when building, extending, or reviewing an Activepieces piece, its actions, its triggers, or a flow that wires Activepieces to a service. | `activepieces` |
| Use when the orchestrator composes or dispatches a worker package, picks a role, verifies evidence, or consolidates escalations. | `agent-delegation` |
| Use when choosing a stack or architecture, when how to structure this comes up, or before any real feature is built. | `architecture-and-skeleton` (+ `agent-delegation`) |
| Use when building, extending, or reviewing Avo resources, fields, actions, dashboards, cards, or authorization in the user's Rails modules or applications. | `avo` (+ `rails`) |
| Use when the user attaches, detaches, or checks the Beeper↔opencode bridge — including 'establish a bridge connection to Beeper', 'I'm going AFK', or 'delegate this to Beeper'. | `beeper-bridge` |
| Use when writing, reviewing, or refactoring code, when judging whether a unit is too big, too clever, or too deeply nested, or when asking whether code is clean. | `clean-code` (+ `self-documenting-code`) |
| Use when reviewing a pull request or change, or when preparing a change for review. | `code-review` (+ `edge-case-analysis`, `security-review`, `threat-modeling`) |
| Use for all user-facing writing — conversation, summaries, plans, reviews, and teaching — or when the user asks for less AI slop, a different tone, or a style guide. | `communication-standards` |
| Use when the user is editing or creating opencode's own configuration — opencode.json, .opencode/, or ~/.config/opencode/ — including agents, subagents, skills, plugins, MCP servers, and permission rules. | `customize-opencode` |
| Use when a brief is vague, when starting discovery, or when the user hands over raw material and asks to figure out what we're building. | `discovery-interview` (+ `agent-delegation`) |
| Use when creating or changing a Docker or Docker Compose dev environment — adding a service to docker-base, extending a language wrapper, wiring a project's compose, or defining the production image. | `docker` |
| Use when reviewing code for edge cases, crashes, hangs, and denial-of-service, or as the robustness step of a red-team review. | `edge-case-analysis` |
| Use when writing or updating a feature spec, or when a slice needs its acceptance criteria pinned. | `feature-spec` (+ `agent-delegation`) |
| Use when building, extending, or reviewing Filament resources, forms, tables, plugins, or pages in the user's Laravel modules or applications. | `filament` (+ `laravel`) |
| Use when the user asks to commit, branch, merge, rebase, stash, push, pull, open or review a pull request, file or triage an issue, create a release, author a CONTRIBUTING.md, or when starting work in a repo and the workflow needs to be determined. | `git-workflow` |
| Use when reading or triaging GitHub issues, joining or posting in discussions, sending updates, or creating pull requests that reference issues. | `github` (+ `git-workflow`) |
| Use when the orchestrator needs a single classification call — a triage decision, routing a task to a skill, matrix row, or worker role, or deciding whether to escalate to the advisor. | `jev-gates` |
| Use when deploying to Kubernetes, writing or changing a Helm chart, wiring Flux, handling cluster secrets, or working with k3s, cert-manager, GHCR, or the kubernetes-* repos. | `kubernetes` |
| Use when building, extending, or reviewing Laravel or PHP code in the user's style, or when the task references their modules, ServiceProvider, composer wiring, or Eloquent mechanics. | `laravel` (+ `software-architecture`, `software-testing`) |
| Use when reading or writing HOT.md, recording episodic events, updating semantic memory, running reflection, or when the user says consolidate memory. | `memory` |
| Use when starting a new project from scratch, scaffolding a new repo, creating a new Laravel app or module, or setting up a fresh development environment. | `new-project` (+ `git-workflow`, `skeleton-ecosystem`) |
| Use when building, extending, or releasing an Obsidian community plugin in any repository. | `obsidian-plugin` |
| Use when scrutinising an existing system or a module's architecture against its spec with fresh eyes, when a design feels over-engineered, or before any re-architecture, at system scale. | `premise-demolition` (+ `systems-thinking`) |
| Use when starting a new project, setting up the foundation, or seeding a repo for spec-driven delivery. | `project-seed` (+ `new-project`) |
| Use when building, extending, or reviewing Ruby on Rails code, engines, modules, action objects, DTOs, ActiveRecord models, Hotwire views, or Packwerk boundaries in the user's repos. | `rails` (+ `software-architecture`, `software-testing`) |
| Use when a change's main job is a behaviour-preserving restructure of code, at any scale, including when deciding how much machinery the refactor deserves. | `refactoring` |
| Use when running the research-prompt-skills scheduled job or when asked to do a prompt, memory, context, or skill research sweep. | `research-prompt-skills` |
| Use when reviewing a diff or codebase for security issues, or as the core red-team step of a code review. | `security-review` |
| Use when writing, reviewing, or refactoring code, when deciding whether a comment earns its place, or for any question of code style, formatting rhythm, blank lines, or error-message wording. | `self-documenting-code` |
| Use when shaping a piece of work, setting an appetite, betting on a cycle, tracking a hill, or sizing a slice. | `shape-up` |
| Use when working with a Shopify store programmatically — acquiring or running the Shopify CLI, authenticating to a store, or running Admin GraphQL reads, mutations, or bulk operations against products, variants, prices, inventory, or orders. | `shopify` |
| Use when scaffolding or adopting a repo, choosing a skeleton, or wiring a devshell, workflows or shared config. | `skeleton-ecosystem` |
| Use when creating a new SKILL.md, editing or extending an existing skill, or formalizing a workflow as a reusable agent skill per the Agent Skills specification. | `skill-authoring` (+ `skill-design-principles`) |
| Use before authoring or changing a skill when checking prior art, deciding whether a skill is needed, what belongs in it, or whether the thing is a skill or a role. | `skill-design-principles` |
| Use when resolving which skills govern a task, reading or changing the routing matrix, or composing a worker's governing set. | `skill-loading` |
| Use when starting or delivering a slice, or when the user asks to build the next slice. | `slice-delivery` (+ `agent-delegation`, `git-workflow`) |
| Use when designing, building, extending, or reviewing the architecture of any OO codebase, or when deciding where logic lives, how a use case is shaped, or how a port or DTO is defined. | `software-architecture` (+ `software-architecture-structure`) |
| Use when creating, moving, naming, or placing a class or file, choosing a folder, picking a role suffix, adding a module, or reviewing a repository's structure. | `software-architecture-structure` |
| Use when building, extending, refactoring, or reviewing code in any language or repository, or when deciding how to structure a change. | `software-development` (+ `clean-code`) |
| Use when writing, extending, or reviewing tests, or when deciding what to test and how to structure a test suite. | `software-testing` |
| Use when the user changes their mind mid-build, when a requirement shifts, or when implementation surfaces an ambiguity the spec does not cover. | `spec-change` (+ `agent-delegation`) |
| Use when scheduling a recurring agent job, adding, removing, or changing a scheduled job, or inspecting why a scheduled run behaved a certain way. | `systemd-scheduler` |
| Use when modelling a system or feature for the first time, when asked whether a design is right, or as the first move of a re-architecture. | `systems-thinking` |
| Use when the user wants to learn a subject — 'teach me X', 'walk me through X', 'give me a lesson on X', or 'explain X to me' with a learning intent. | `teach-mode` |
| Use when reviewing architecture or design for security, scoping a security review, or as the first step of a red-team or adversarial review. | `threat-modeling` |
| Use when writing, extending, or reviewing TypeScript or Node code, naming an interface or type, deciding a module's export shape, wiring dependencies, or configuring tsconfig. | `typescript` (+ `software-architecture`) |
| Use when converting a markdown document to a PDF, creating an offerte or contract, or rendering a document with the 99linesofcode typst template. | `typst-document` |
| Use when creating or maintaining a note, person, organization, project, or meeting in the Obsidian vault, or when reorganizing or cleaning the vault. | `vault-notes` |
| Use when ingesting a source from the vault Inbox, querying the wiki, or linting wiki health. | `wiki` |
<!-- generated:end -->

**Row grammar.** The matrix is generated — never hand-edit it. Each row names a
skill and, in parentheses, the skills it `Loads` (the linter enforces it);
skills joined by a bare ` + ` are co-equal primaries.

## Resolving a task

The `matrix_row` gate (`jev-gates`) picks one row — a flat choice over the
route-when sentences. That row **is** the required set. `resolve-skills.mjs`
then expands it: the transitive `Loads` closure (capped at 4) is the governing
set, alongside the required files and External pointers, and the on-demand list
(the row's `References`, one hop, with their triggers).

**Deterministic resolution.** The row is resolved at work-start /
package-composition time. Never rely on the model remembering to load
"related" skills.

**Fail closed.** If any governing skill in the row cannot be loaded, the work
does not start. Partial activation is a defect, not a degraded mode.

**Bundles.** When a set of skills must ALWAYS activate together and partial
activation would be wrong, prefer a composite skill (one directory, one
description, components as references) over hoping the model loads a set.

## The graph, and what walks it

`Loads` is walked transitively — it is the required set. `References` is not: it
is listed one hop and read on demand. `catalog.json` records the whole graph
(`loads` + `references` per skill); the generated block above, the tables in
`agent-delegation`, and the option sets in `gates.json` are all rendered from it.

## Precedence when skills overlap

Platform/system policy → `AGENTS.md` (user/org policy) → skill contracts →
task-specific user instructions. Within a cluster, one skill owns a rule; two
skills defining the same rule differently is a defect to fix at the source.
