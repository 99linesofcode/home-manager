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

- **Loads:** `clean-code` (the code-quality umbrella every change answers to).
- **References:** `software-architecture`, `software-testing`, `git-workflow`,
  `self-documenting-code`, `new-project`, `code-review`, `skill-loading` (the
  library-navigation contract), `skill-authoring` (how a skill is written).

## The skill gate (always, before any meaningful work)

Before starting any meaningful software development work — planning, building,
extending, refactoring, reviewing, or dispatching a worker — **identify the
governing skills and load them. Then follow them religiously; they are
contracts, not suggestions.** The library's navigation — the routing matrix,
the `Loads` closure, fail-closed activation, precedence — is `skill-loading`.

- **Worker or otherwise:** a worker package must name its governing skills and
  instruct the worker to load and follow them. A package — or a work session —
  composed from memory for a skill-governed operation is a defect: paraphrases
  drop steps — a scaffold dispatched without `new-project` ships the wrong
  package manager and no devshell; feature commits pushed straight to `main`
  with `git-workflow` never loaded.
- When in doubt whether a skill governs, load it. Loading is cheap; a dropped
  step is not.

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

