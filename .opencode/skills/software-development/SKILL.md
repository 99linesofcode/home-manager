---
name: software-development
description: The user's software development discipline — load the governing skills, then work in small verifiable changes with cleanup built in. Removes dangling code, messy history, and cleanup-later debt. Use when building, extending, refactoring, or reviewing code in any language or repository, or when deciding how to structure a change.
metadata:
  category: delivery
  route-when: "Use when building, extending, refactoring, or reviewing code in any language or repository, or when deciding how to structure a change."
---

# software-development

The user's standard for how code changes are made and committed. The goal: no
dangling code, no messy history, no "cleanup later" debt — cleanup is part of
the work, not a follow-up task.

Language- and framework-agnostic. Git mechanics (committing, squashing,
history hygiene) live in the `git-workflow` skill.

## Related

- **Loads:** (none — this is the gate; it routes via the matrix above)
- **References:** `software-architecture`, `software-testing`,
  `git-workflow`, `self-documenting-code`, `new-project`,
  `code-review`, `skill-authoring` (the routing-matrix convention)
  (the cluster the matrix routes to).

## The skill gate (always, before any meaningful work)

Before starting any meaningful software development work — planning,
building, extending, refactoring, reviewing, or dispatching a worker —
**identify the governing skills and load them. Then follow them religiously;
they are contracts, not suggestions.**

- Governing skills by task — **the routing matrix** (single authoritative
  lookup for the software development cluster; when a skill is added,
  renamed, or rescoped, its row changes here — see `skill-authoring`):

<!-- generated:start — do not edit; regenerate with build-catalog.mjs -->
| Task | Governing skills |
|---|---|
| Use when the orchestrator composes or dispatches a worker package, picks a role, verifies evidence, or consolidates escalations. | `agent-delegation` |
| Use when choosing a stack or architecture, when how to structure this comes up, or before any real feature is built. | `architecture-and-skeleton` (+ `agent-delegation`) |
| Use when building, extending, or reviewing Avo resources, fields, actions, dashboards, cards, or authorization in the user's Rails modules or applications. | `avo` (+ `rails`) |
| Use when reviewing a pull request or change, or when preparing a change for review. | `code-review` (+ `edge-case-analysis`, `security-review`, `threat-modeling`) |
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
| Use when starting a new project from scratch, scaffolding a new repo, creating a new Laravel app or module, or setting up a fresh development environment. | `new-project` (+ `git-workflow`, `skeleton-ecosystem`) |
| Use when building, extending, or releasing an Obsidian community plugin in any repository. | `obsidian-plugin` |
| Use when scrutinising an existing system or a module's architecture against its spec with fresh eyes, when a design feels over-engineered, or before any re-architecture, at system scale. | `premise-demolition` (+ `systems-thinking`) |
| Use when starting a new project, setting up the foundation, or seeding a repo for spec-driven delivery. | `project-seed` (+ `new-project`) |
| Use when building, extending, or reviewing Ruby on Rails code, engines, modules, action objects, DTOs, ActiveRecord models, Hotwire views, or Packwerk boundaries in the user's repos. | `rails` (+ `software-architecture`, `software-testing`) |
| Use when a change's main job is a behaviour-preserving restructure of code, at any scale, including when deciding how much machinery the refactor deserves. | `refactoring` |
| Use when reviewing a diff or codebase for security issues, or as the core red-team step of a code review. | `security-review` |
| Use when writing, reviewing, or refactoring code, when deciding whether a comment earns its place, or for any question of code style, formatting rhythm, blank lines, or error-message wording. | `self-documenting-code` |
| Use when shaping a piece of work, setting an appetite, betting on a cycle, tracking a hill, or sizing a slice. | `shape-up` |
| Use when scaffolding or adopting a repo, choosing a skeleton, or wiring a devshell, workflows or shared config. | `skeleton-ecosystem` |
| Use when creating a new SKILL.md, editing or extending an existing skill, or formalizing a workflow as a reusable agent skill per the Agent Skills specification. | `skill-authoring` (+ `skill-design-principles`) |
| Use before authoring a skill when deciding whether a skill is needed, what belongs in it, or whether the thing is a skill or a role. | `skill-design-principles` |
| Use when starting or delivering a slice, or when the user asks to build the next slice. | `slice-delivery` (+ `agent-delegation`, `git-workflow`) |
| Use when designing, building, extending, or reviewing the architecture of any OO codebase, or when deciding where logic lives, how a use case is shaped, or how a port or DTO is defined. | `software-architecture` (+ `software-architecture-structure`) |
| Use when creating, moving, naming, or placing a class or file, choosing a folder, picking a role suffix, adding a module, or reviewing a repository's structure. | `software-architecture-structure` |
| Use when building, extending, refactoring, or reviewing code in any language or repository, or when deciding how to structure a change. | `software-development` |
| Use when writing, extending, or reviewing tests, or when deciding what to test and how to structure a test suite. | `software-testing` |
| Use when the user changes their mind mid-build, when a requirement shifts, or when implementation surfaces an ambiguity the spec does not cover. | `spec-change` (+ `agent-delegation`) |
| Use when scheduling a recurring agent job, adding, removing, or changing a scheduled job, or inspecting why a scheduled run behaved a certain way. | `systemd-scheduler` |
| Use when modelling a system or feature for the first time, when asked whether a design is right, or as the first move of a re-architecture. | `systems-thinking` |
| Use when reviewing architecture or design for security, scoping a security review, or as the first step of a red-team or adversarial review. | `threat-modeling` |
| Use when writing, extending, or reviewing TypeScript or Node code, naming an interface or type, deciding a module's export shape, wiring dependencies, or configuring tsconfig. | `typescript` (+ `software-architecture`) |
<!-- generated:end -->

  Routing rules: the matrix routes the task; each skill's `description`
  carries the trigger keywords for every task it governs (the discovery
  layer — a task that routed wrong means a description and/or row defect);
  cross-references stay in each skill's `## Related` (Loads = required
  companions, References = on-demand — navigation, not routing).

  Row grammar: the matrix is generated (do not hand-edit). Each row names a
  skill and, in parentheses, the skills it `Loads` (the linter enforces it);
  skills joined by a bare ` + ` are co-equal primaries. The linter parses this
  table: every named skill must exist, and every `(+ …)` companion must be in
  the primary's `Loads`.

  Activation rules:

  - **Deterministic resolution:** the orchestrator resolves the matrix row
    at work-start / package-composition time — the row IS the required set.
    Never rely on the model remembering to load "related" skills.
  - **Fail closed:** if any governing skill in the row cannot be loaded, the
    work does not start. Partial activation is a defect, not a degraded
    mode.
  - **Precedence when skills overlap:** platform/system policy → `AGENTS.md`
    (user/org policy) → skill contracts → task-specific user instructions.
    Within a cluster, one skill owns a rule; two skills defining the same
    rule differently is a defect to fix at the source.
  - **Bundles:** if a set of skills must ALWAYS activate together and
    partial activation would be wrong, prefer a composite skill (one
    directory, one description, components as references) over hoping the
    model loads a set. Dependency manifests, version pinning, and capability
    profiles are machinery for larger skill libraries — defer until the
    library demands it.
- **Worker or otherwise:** a worker package must name its governing skills
  and instruct the worker to load and follow them. A package — or a work
  session — composed from memory for a skill-governed operation is a
  defect: paraphrases drop steps — a scaffold dispatched without `new-project`
  ships the wrong package manager and no devshell; feature commits pushed
  straight to `main` with `git-workflow` never loaded.
- When in doubt whether a skill governs, load it. Loading is cheap; a
  dropped step is not.

## The change chain (always)

**Task → use cases → separate changes → individual atomic commits.** Every
task is decomposed into use cases (one user story each); every use case
becomes its own separate change; every change lands as an individual atomic
commit. No task is exempt — future slices get the same decomposition when
their turn comes, never a bundled batch.

- **One concern per change.** One use case, one feature, one fix, one
  refactor. Multiple concerns → sequential changes, never a mixed one.
- **TDD is a hard requirement.** The use-case definition is the spec; write
  the failing test, then the code — never the reverse. See the
  `software-testing` skill.
- **Verify as you go.** Run the project's checks (typecheck, tests, build,
  lint) after every change. A change that doesn't verify is not done.
- **Commit immediately.** A verified use case lands as its own atomic commit;
  never accumulate uncommitted work across use cases.

## Clean up as you go (the anti-dangling rule)

When a change supersedes or invalidates existing code, remove the dead code
**in the same change** — not later:

- Removed a call site → delete the now-unused function, type, import, or
  parameter.
- Changed a design direction → delete what the old direction left behind
  (dead branches, unused helpers, superseded modules).
- Changed a contract → update callers, docs, and config.
- After every change, grep for dangling references to anything renamed or
  removed. A symbol with no callers is dead — remove it or justify keeping
  it.

The test: after every change, the tree contains no code unreachable from a
live entry point, and no docs describing behavior that doesn't exist.

### Docs are part of the change

User-facing docs rot fastest: README, spec, wiki pages, and comments that
describe behavior. On every feature or refactor:

- Update the docs describing the changed behavior **in the same change**.
- At review/merge time, **re-read** the affected docs and confirm they
  describe the behavior that now exists — not the behavior that used to.
- Inherited boilerplate (e.g. a skeleton README) counts as stale the moment
  the project diverges from it — rewrite it for the project, don't patch it.

## The environment (devshells)

Repos carry a Nix devshell (flake + `.envrc`) — the environment the
project's gates are defined against. Run project commands through it:

- `direnv exec . <cmd>` from the repo root (works without a hooked shell).
- Fall back to `nix develop -c <cmd>` or `nix run nixpkgs#<tool> -- <args>`
  when direnv isn't available.

Never bypass the devshell with ad-hoc global binaries; a gate run outside
the devshell proves nothing about the environment the change ships in.

## The definition of done

A change is done when all of these hold:

- [ ] It works — verified by running it.
- [ ] It's tested — spec → test → code; the suite passes.
- [ ] It's atomic — one concern (one use case), one change.
- [ ] It's clean — no dead code, no dangling references; affected docs
      updated in the same change.
- [ ] It's formatted — the formatter ran as part of the change, never
      deferred to a later cleanup.
- [ ] The diff contains only this change's concern.
- [ ] It's committed with a clear Conventional Commit message; history is
      squashed by feature before push when it spanned multiple commits.

