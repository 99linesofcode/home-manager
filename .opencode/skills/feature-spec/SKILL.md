---
name: feature-spec
description: Write one feature spec with stable IDs, testable WHAT-not-HOW rules, and Given/When/Then scenarios citing those IDs; mark proposed edge cases PROPOSED; then have a fresh spec adversary attack it before it is accepted. Use when writing or updating a feature spec, or when a slice needs its acceptance criteria pinned.
---

# feature-spec

Phase 3. One small spec per feature, written before the code it governs. The
spec is the source; the tests are its executable expression.

## When to use

- Writing a new feature spec.
- Updating a spec because intent changed (pair with `spec-change`).

## Inputs

- `brief.md`, `decisions.md`, `open-questions.md`, relevant sibling specs.

## Format

Use `assets/spec.template.md`:

- **Purpose & non-goals** (3–5 lines)
- **Rules**, each with a stable ID (`SR-1`, `SR-2`, …), written as testable
  statements of WHAT and WHY
- **Scenarios** in Given/When/Then, each citing the rule ID(s) it covers
- **PROPOSED edge cases** — clearly marked, not decided
- **Open questions** specific to this feature

## Constraints

- Describe WHAT and WHY, never HOW.
- Every rule must be verifiable by an automated test. If it can't be phrased
  that way, it belongs in open questions.
- Resolve no open question.

## Then attack it

Dispatch a **spec adversary** with the spec + brief only. Route each finding to
a resolution or to `open-questions.md`. Do not accept the spec until it has been
attacked and its findings dispositioned.

## Delegating

- **spec writer** — drafts the spec.
- **spec adversary** — attacks it, in a fresh context.

## Outputs

- `planning/<slug>/specs/<Fxx>-<name>.md`
- updated `open-questions.md`

## Exit criteria

- Every rule has an ID and at least one scenario.
- The adversary pass is done and its findings dispositioned.
- The user has seen the spec.

## Must not

- Describe implementation.
- Resolve an open question.
- Accept a spec that hasn't been attacked.

## Related

- **Loads:** `agent-delegation`.
- **References:** `software-testing` (scenario shape), `spec-change`.
