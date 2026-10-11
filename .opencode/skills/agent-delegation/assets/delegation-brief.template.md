# Delegation brief — <slice / task id>

**Role:** <name; path to its brief under agent-delegation/references/roles/>
**Purpose:** <one sentence>
**Goal & exit criteria:** <what done looks like, measurably>

## Governing skills (from `resolve-skills.mjs`)

Filled from the resolver for this task's matrix row. The worker reads exactly
these with `read`, before its first edit; a missing one is a blocker.

- `~/.config/opencode/skills/<name>/SKILL.md` — <the rule it binds this task to>
- <one line per skill in the Loads closure, in order>
- <if a governing skill refers to its own references/, assets/ or scripts/, add that file's absolute path too>

## Load-bearing pointers (the worker must open each)

Every `required` file and `required` External pointer the resolver emitted:

- `<absolute path>` — <why>
- `<absolute path>` — <why>  `[MISSING on this machine]` if the resolver flagged it

**On-demand pointers whose trigger matches this task** — add them here too; the
trigger firing means the file is load-bearing for this package:

- `<absolute path>` — <the trigger that fired>

## Inline digest (rules the worker cannot look up)

Copy **verbatim** the rules whose source is outside the worker's reach: the
always-on card below, and any rule that lives only in the orchestrator's context
or in a skill the worker is not handed. Never paraphrase a governing rule — a
paraphrase drops steps.

<!-- card:start -->
## Always-on card (software architecture)

**The module tree** — a module is the repo (or one package); its interior:

```
<module root>/
├── ui/              # driving adapters: controllers, commands, schedulers
├── core/
│   ├── application/ # actions, data (DTOs), queries, services, listeners
│   ├── domain/      # models, enums, events, errors, rules, services
│   └── port/        # the interfaces the core owns
└── infrastructure/  # driven adapters: one folder per tool, then vendor
```

A single-context module has no component wrapper — `application/`, `domain/`,
`port/` sit directly under `core/`.

**Roles are suffixes (closed table).** `Action`, `Port`, `Adapter`,
`DataTransferObject`, `Service`, `Query`, `Event`, `Listener`, `Mapper`,
`Parser`, `Rule`, `State`, `QueryBuilder`, `Collection`, `Factory`, `Error`,
`Controller`, `Command`, `Request`, `Resource`, `ViewModel`, `Scheduler`.
Carve-outs with no suffix: domain models (`Post`), descriptive enums
(`PostStatus`). A project needing an extra role adds it in its own repo-local
skill.

**Three hard rules:**
1. Dependencies point inward — `ui → core ← infrastructure`; nothing depends
   on `ui` or `infrastructure`.
2. No provider shapes in the core — canonical DTOs only; provider names only in
   the provider module.
3. One class per file; the file name matches the symbol.
<!-- card:end -->

## Environment

- Platform: NixOS; the project devshell is the environment the gates run in.
- Repository / working directory: <absolute path> — confirm with `pwd`, `git remote -v`, `git log`; never assume which repository you are in.
- Devshell: `direnv exec . <cmd>` from the repo root, or `nix develop -c <cmd>`; `nix run` for a one-off tool. Never bypass it with a global binary.
- Gates: <exact commands: typecheck, lint, boundaries, test, build>.
- One worktree per worker — do not fight another session over HEAD.

## Read (exhaustive)

- <absolute path> — <why>

## May create / change

- <path or glob>

## Must not touch

- <path or glob>

## Constraints & principles

- <the distilled rule that binds this task>

## Output

- Location: <path>
- Format: <template / shape>

## Stop and ask

- <condition>
- <condition>
