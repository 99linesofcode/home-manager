---
name: agent-delegation
description: Compose and dispatch worker packages, verify their evidence, and consolidate escalations. Defines the reusable role briefs (material analyst, spec writer, spec adversary, options analyst, spike engineer, characterization test author, acceptance test author, implementer, reviewer, spec reconciler) and the delegation-brief and worker-report templates. Use whenever the orchestrator dispatches a worker, in any phase of spec-driven delivery.
---

# agent-delegation

How the orchestrator hands work to workers. Every phase skill delegates through
this one. Workers start cold, cannot ask the user anything, and know only what
the package carries — so the package is the whole game.

## When to use

- Before dispatching any `task` worker, in any phase.
- When composing a delegation brief or reading a worker report.

## The rules

1. **Self-contained.** A package carries role, purpose, inputs to read
   (exhaustive paths), permitted outputs, constraints (skills by reference),
   exit criteria, and stop-and-ask conditions. Assume the worker knows nothing
   from our conversation.
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

## Dispatching

- Spawn via the `task` tool (`subagent_type: worker`). Multiple calls in one
  message run in parallel.
- Workers are `skill: deny` — they cannot load skills. The package names the
  governing skills by path (`~/.config/opencode/skills/<name>/SKILL.md`) **and**
  distills the contract requirements for this task. Never assume a worker read
  a skill.
- Workers can `read` files. Pass role briefs by path:
  `~/.config/opencode/skills/agent-delegation/references/roles/<role>.md`.
- Write scope is a package constraint, not an ACL — opencode permissions are
  per-agent, not per-task. The reviewer checks the diff against the stated scope.

## Composing a package

Use `assets/delegation-brief.template.md`. Fill every section; an empty
stop-and-ask section is a defect.

## Receiving a report

Use `assets/worker-report.template.md`. A report missing evidence, or carrying
assumptions where there should be none, is not accepted — return it for the
missing evidence, or escalate. **Paste the raw gate and test output; "tests
pass" without the run is not evidence.**

## Escalations

Consolidate and deduplicate before they reach the user. Each escalation carries
what was ambiguous or conflicting, the options, and your recommendation. The
user decides.

## Related

- **Loads:** (none — loaded on demand by every phase skill)
- **References:** `software-development` (the discipline this serves),
  `git-workflow` (delivery), the role briefs in `references/roles/`.
