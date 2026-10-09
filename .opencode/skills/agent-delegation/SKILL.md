---
name: agent-delegation
description: Compose and dispatch worker packages, resolve each package's governing skills from the role → skills routing matrix, verify the evidence, and consolidate escalations. Defines the reusable role briefs (material analyst, spec writer, spec adversary, options analyst, spike engineer, characterization test author, acceptance test author, implementer, reviewer, spec reconciler) and the delegation-brief and worker-report templates. Use whenever the orchestrator dispatches a worker, in any phase of spec-driven delivery.
---

# agent-delegation

How the orchestrator hands work to workers. Every phase skill delegates through
this one. Workers start cold, cannot ask the user anything, and know only what
the package carries — so the package is the whole game.

## When to use

- Before dispatching any `task` worker, in any phase.
- When composing a delegation brief or reading a worker report.

## The rules

1. **Self-contained.** A package carries role, purpose, the governing skills
   (by path — see _Governing skills_), the environment (see _Environment_),
   inputs to read (exhaustive paths), permitted outputs, constraints, exit
   criteria, and stop-and-ask conditions. Assume the worker knows nothing from
   our conversation.
2. **One role per worker.** Never combine roles that must stay independent:
   test author + implementer, implementer + reviewer, spec writer + spec
   adversary.
3. **Independence is what you withhold.** The reviewer gets spec + diff +
   results, never the implementer's reasoning. The test author never sees the
   implementation. The spec adversary gets the spec + brief only.
4. **Workers never decide.** On ambiguity, conflict, or a test they believe is
   wrong: stop and report. You consolidate escalations and bring them to the
   user with options and a recommendation.
5. **You accept evidence, not claims.** Gate output, test results, and an
   independent review — never "done".
6. **Size to context.** One worker, one task that fits comfortably. If it
   doesn't fit, split it.
7. **Parallelism needs disjoint write scopes.** State each worker's write scope
   explicitly and verify no two overlap before dispatching in one message.
8. **Sequence shared-scope roles.** Never run two roles in parallel that touch
   the same files — in particular the acceptance-test author and the
   implementer: the tests are written, reviewed, and **locked** before the
   implementer starts. Parallelism is for genuinely independent work.

## Governing skills (every package)

A worker cannot self-select skills (`skill: deny`). The package must name the
governing skill files for the worker's role, by path, and the worker reads
exactly those with `read` — never browsing for others. A package that omits
them is a defect: the worker is left working from your paraphrase.

Resolve the role against this matrix and put every listed path in the package:

| Role                         | Governing skills                                                                         |
| ---------------------------- | ---------------------------------------------------------------------------------------- |
| material analyst             | `discovery-interview`                                                                    |
| options analyst              | `architecture-and-skeleton`, `software-architecture`                                     |
| spike engineer               | `architecture-and-skeleton`                                                              |
| spec writer                  | `feature-spec`                                                                           |
| spec adversary               | `feature-spec`                                                                           |
| spec reconciler              | `feature-spec`, `spec-change`                                                            |
| characterization test author | `software-testing`                                                                       |
| acceptance test author       | `software-testing`                                                                       |
| implementer                  | `software-architecture`, `software-development`, `self-documenting-code`, `git-workflow` |
| reviewer                     | `code-review`, plus the change's own governing skills                                    |

This matrix routes **roles** — what a worker does. The task-level matrix as in
the `software-development` routes **tasks**. Both are authoritative for their
axis; when a skill is added, renamed, or rescoped, update its row in both.

Name each skill as `~/.config/opencode/skills/<name>/SKILL.md`. If a named skill
refers to a file under its own `references/`, `assets/` or `scripts/`, give that
file's absolute path too — a raw `read` carries no base directory, so a bare
relative reference will not resolve.

## Environment (every package)

Every worker starts cold in the same machine environment, and the package is
where it learns that environment. A package that omits it is a defect — the
worker then guesses at the devshell, or runs a gate with a global binary and
proves nothing. Carry this block, filled in for the task:

- **Platform.** NixOS. The project's devshell is the environment its gates are
  defined against.
- **Repository & working directory.** <absolute repo path> — the worker confirms
  with `pwd`, `git remote -v`, `git log` before acting; never assume which
  repository it is in.
- **Devshell.** Run every project command through it: `direnv exec . <cmd>` from
  the repo root, or `nix develop -c <cmd>`; `nix run` for a one-off tool. When a
  package manager is unavailable, invoke the underlying binaries directly (e.g.
  `node_modules/.bin/vitest run`). Never bypass the devshell with a global
  binary — a gate run outside it proves nothing about the environment the change
  ships in.
- **Gates.** <the exact commands: typecheck, lint, boundaries, test, build>.
- **One session per working directory.** Do not fight another session over HEAD.

The role briefs carry the same block as the worker's reminder; the package is the
binding copy, and it names the concrete repository and gates.

## Dispatching

- Spawn via the `task` tool (`subagent_type: worker`). Multiple calls in one
  message run in parallel.
- Workers cannot self-select skills (`skill: deny`). Name the governing skill
  files for the role, by path (see _Governing skills_); the worker reads exactly
  those. Never assume a worker read a skill it was not handed.
- Workers can `read` files. Pass role briefs by path:
  `~/.config/opencode/skills/agent-delegation/references/roles/<role>.md`.
- Write scope is a package constraint, not an ACL — opencode permissions are
  per-agent, not per-task. The reviewer checks the diff against the stated scope.

## Composing a package

Use `assets/delegation-brief.template.md`. Fill every section — including
_Governing skills_ and _Environment_; an empty stop-and-ask section is a defect.

## Receiving a report

Use `assets/worker-report.template.md`. A report missing evidence, or carrying
assumptions where there should be none, is not accepted — return it for the
missing evidence, or escalate. **Paste the raw gate and test output; "tests
pass" without the run is not evidence.** A report that does not confirm the
provided skills were read, and the environment honoured, is incomplete — return
it, do not accept it.

## Escalations

Consolidate and deduplicate before they reach the user. Each escalation carries
what was ambiguous or conflicting, the options, and your recommendation. The
user decides.

## Related

- **Loads:** (none — loaded on demand by every phase skill)
- **References:** `software-development` (the task-level routing matrix),
  `git-workflow` (delivery), the role briefs in `references/roles/`.
