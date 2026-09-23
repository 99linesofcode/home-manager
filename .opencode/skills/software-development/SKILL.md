---
name: software-development
description: The user's software development discipline — the skill gate (governing skills loaded and followed before any meaningful work, worker or otherwise), the change chain (task → use cases → separate changes → individual atomic commits), TDD, verify-as-you-go, cleanup-as-you-go (no dangling code), and a definition of done. Applies to every software development context (any language, framework, or repo). Use when building, extending, refactoring, or reviewing code, or when deciding how to structure a change.
---

# software-development

The user's standard for how code changes are made and committed. The goal: no
dangling code, no messy history, no "cleanup later" debt — cleanup is part of
the work, not a follow-up task.

Language- and framework-agnostic. Git mechanics (committing, squashing,
history hygiene) live in the `git-workflow` skill.

## The skill gate (always, before any meaningful work)

Before starting any meaningful software development work — planning,
building, extending, refactoring, reviewing, or dispatching a worker —
**identify the governing skills and load them. Then follow them religiously;
they are contracts, not suggestions.**

- Governing skills by task — **the routing matrix** (single authoritative
  lookup for the software development cluster; when a skill is added,
  renamed, or rescoped, its row changes here — see `skill-authoring`):

  | Task | Governing skills |
  |---|---|
  | Create a repository / scaffold a project | `new-project` (+ `git-workflow`, `software-architecture`) |
  | Any git or GitHub operation (branch, commit, PR, release) | `git-workflow` |
  | Write, extend, or review code (any language) | `software-architecture` + `software-development` |
  | Write or review tests | `software-testing` |
  | Code style: naming, comments, whitespace, formatting rhythm | `self-documenting-code` |
  | Laravel specifics (actions, DTOs, modules) | `laravel` |
  | Filament UI work | `filament` (+ `laravel`) |
  | Review a change end-to-end | `code-review` (+ that change's governing skills) |
  | Security review / red-team | `code-review` (Loads `security-review`, `threat-modeling`, `edge-case-analysis`) |
  | Plan or dispatch multi-session work | `wayfinder` |

  Routing rules: the matrix routes the task; each skill's `description`
  carries the trigger keywords for every task it governs (the discovery
  layer — a task that routed wrong means a description and/or row defect);
  cross-references stay in each skill's `## Related` (Loads = required
  companions, References = on-demand — navigation, not routing).

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
  defect: paraphrases drop steps (2026-09-18: a scaffold dispatched without
  `new-project` shipped the wrong package manager and no devshell; feature
  commits pushed straight to `main` with `git-workflow` never loaded).
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

## The definition of done

A change is done when all of these hold:

- [ ] It works — verified by running it.
- [ ] It's tested — spec → test → code; the suite passes.
- [ ] It's atomic — one concern (one use case), one change.
- [ ] It's clean — no dead code, no dangling references; affected docs
      updated in the same change.
- [ ] The diff contains only this change's concern.
- [ ] It's committed with a clear Conventional Commit message; history is
      squashed by feature before push when it spanned multiple commits.

## Related

- **Loads:** (none — this is the gate; it routes via the matrix above)
- **References:** `software-architecture`, `software-testing`,
  `git-workflow`, `self-documenting-code`, `new-project`, `wayfinder`,
  `code-review` (the cluster the matrix routes to).
