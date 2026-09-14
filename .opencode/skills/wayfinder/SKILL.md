---
name: wayfinder
description: Orchestration protocol for large, multi-session planning. Fog-of-war decision ticket maps, interview-first discovery, dense spec generation, scoped worker dispatch into a Karpathy-style vault. GitHub is a destination, not the model.
license: MIT
---

# Wayfinder

Protocol for turning a large, vague idea into a dense, approved spec and a queue
of bounded implementation tickets without overflowing context.

Wayfinder is a **thinking model**, not a tool integration. It runs against the
vault and is identical whether the ticket destination is GitHub, Todoist, or a
plain file. GitHub (Issues/PRs/Projects) is an *input* and an *output* of the
protocol, never part of how it thinks.

## OKF conformance

Wayfinder's persistent artifacts are **OKF v0.2 concepts**:

- `planning/<slug>/map.md`     → `type: Decision Map`
- `planning/<slug>/interviews.md` → `type: Interview Log`
- `planning/<slug>/research/*.md` → `type: Research` (or `Attested Computation`)
- `planning/<slug>/spec.md`    → `type: Spec`
- `specs/<slug>.md` (promoted) → `type: Spec`, `status: stable`, `verified`
- `logs/<slug>/<ticket-id>.md` → `type: Session Log`

Each carries `type` + `generated: { by, at }` at minimum. Specs use `status`
(draft→stable) and `verified` (human sign-off) per OKF §5. If a research spike
yields a reproducible computation, express it as an OKF
`type: Attested Computation` (§10) with `runtime`, `parameters`, `executor`, and
`attester`.

## When

When the task is large, greenfield, multi-session, or under-specified.

## Fog of war

At the start you do not know what you do not know. The decision ticket map makes
the fog explicit and resolves it in dependency order, keeping each step's
context bounded (this is ICM — in-context memory — in action).

## Decision tickets

A ticket is a question that must be answered before design can proceed:
- id (stable slug, e.g. `dt-04-storage-format`)
- question
- type: `research` | `prototype` | `discussion` | `real-world`
- blocked-by (ids)
- status: `fogged` | `open` | `in-flight` | `resolved`
- answer (when resolved)
- dispatched-to (worker id or `orchestrator`)

Decision tickets are **internal**. They live in `map.md`, NOT in GitHub. Only
fully-resolved implementation tickets are emitted to GitHub at the end.

## Map

`~/Documents/Obsidian/planning/<slug>/map.md` is the single source of truth for
any active planning effort (`type: Decision Map`).

## Protocol

1. **Interview / seed** — a task may arise from a GitHub Issue, a user request,
   or a vague idea. Use the `question` tool, highest-leverage first, log every
   Q&A to `planning/<slug>/interviews.md`. If inbound is a GitHub Issue, read it
   **scoped** (that issue + bounded comments + relevant files); do not pull
   unrelated repo state. Stop when the shape is clear. Do not over-interview.
2. **Draft map** — write `map.md` with all known/suspected tickets, `blocked-by`,
   and `fogged` status.
3. **Resolve** — dependency order; graph must be a DAG. `discussion`/`research`
   in-session; `prototype` → worker spike; `real-world` → ask the user.
4. **Dispatch** — independent tickets may run workers in parallel. Each package:
   spec excerpt + bounded task + file list. No inter-agent comm; state flows via
   map + files. Worker output → `logs/<slug>/<ticket-id>.md`.
   **Skill gate (mandatory):** before writing a package, name the skill(s)
   that govern the task type (new repo → `new-project`; git delivery →
   `git-workflow`; tests → `software-testing`; architecture →
   `software-architecture`). Either compose the package from the loaded
   skill or instruct the worker to load and follow it. A package written
   from memory for a skill-governed operation is a defect — that is how
   steps get dropped (2026-09-18: a scaffold dispatched without
   `new-project` shipped the wrong package manager and no devshell).
5. **Spec** — when fully resolved, synthesize `planning/<slug>/spec.md` (dense,
   implementation-ready; `type: Spec`, `status: draft`). Present via `question`
   for approval.
6. **Promote + ticket-out** — on approval set `status: stable` and add
   `verified: { by: human:<id>, at: <ISO 8601> }`, move spec to `specs/<slug>.md`.
   Emit **resolved** implementation tickets → GitHub Issues (one per ticket,
   linking the spec section). Mid-flight decision tickets are NEVER mirrored
   into GitHub. **Never touch Todoist** (manual sync).
   **Ticket template** — assume a human reader with little prior knowledge
   needs to make sense of it (Shape Up's pitch elements as the context
   standard): **User story** (what the user can do), **Context** (the
   problem today + what already exists that this builds on), **Scope** (what
   changes, where — accessible terms), **Scenarios** (Given/When/Then),
   **Acceptance criteria**, **Out of scope** (rabbit holes / no-gos). Worker
   packages carry the same shape.
   Delivery mechanics (branching, commits, PRs, releases) follow the
   `git-workflow` skill — load it when executing the ticket-out.
7. **Memory** — update `HOT.md`, append `wiki/log.md`, record durable decisions.

## Spec format (obligatory)

1. Goal  2. Non-goals  3. Constraints  4. Architecture  5. Data model
2. Interfaces  7. Decision log (ticket id + answer + rationale, links map)
3. Implementation tickets (bounded units, acceptance criteria, dependency order)
4. Open questions (explicitly non-blocking)

## Paths

- planning/<slug>/map.md
- planning/<slug>/interviews.md
- planning/<slug>/research/*.md
- planning/<slug>/spec.md
- specs/<slug>.md
- logs/<slug>/<ticket-id>.md

## Cleanup (on task completion)

The folders `planning/`, `specs/`, and `logs/` **remain** as structural
locations in `AI/`. What is transient is the working files wayfinder creates
inside them (map.md, interviews.md, research/, spec.md, worker logs). When the
task completes:

1. **Consolidate** any durable insight into `wiki/concepts/`,
   `memory/semantic/`, or `memory/episodic/` as warranted (the durable output
   of a planning task lives in the wiki, memory, or a skill — not in the
   working files).
2. **Trash or archive** the transient working files for the completed task
   (move to `.trash`, or archive if worth keeping).
3. Do not leave completed working files lying around in `planning/`, `specs/`,
   or `logs/`.
## Related

- **Loads:** `git-workflow` (delivery mechanics at ticket-out).
- **References:** `github` (issues/PRs as destinations), `shape-up`
  (the pitch elements behind the ticket template).
