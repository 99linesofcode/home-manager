---
name: slice-delivery
description: Run one slice end to end — shape it into a task with criterion IDs and architectural constraints, run the spec-delta check, characterization tests, acceptance tests written first and shown to fail for the right reason, lock the tests, implement, run an independent spec review, then reconcile the spec and decisions. Use when starting or delivering a slice, or when the user says "let's build the next slice".
---

# slice-delivery

Phase 6. One slice, start to finish: shape it, pin the behavior, write the tests
first, lock them, implement, review independently, reconcile.

## When to use

- Starting a slice.
- "Let's build the next slice."

## Shape the slice (first)

A slice is a project task of type `slice`. It carries:

- the spec criterion IDs it satisfies,
- a checklist (or subtasks) for the loop below,
- the open questions that must resolve before it starts,
- **the architectural decisions that bind it** — the ADR references and the
  constraints in play, so they travel with the work.

Ordering is the project: pick the next slice, riskiest-unresolved first. There
is no roadmap document. Use `assets/slice-task.template.md`. When the slice
materializes as a GitHub issue, the issue body carries the criterion IDs and the
architectural constraints; the PR restates them in its **Behavior** section.

## Inputs

- `AGENTS.md`, the slice task, the spec, `decisions.md`, `open-questions.md`.

## The loop

1. **Spec-delta check.** Restate what the slice must do and must not change;
   list ambiguity that affects it (a BLOCKING open question stops the slice);
   list existing behavior it could break. Use `assets/spec-delta.template.md`.
   For the interactive part — one question at a time, the ripple-vs-local test
   — see `references/implementation-sparring.md`.
2. **Characterization tests** (only when touching existing behavior) — dispatch
   a **characterization test author**; they must pass on the current code.
3. **Acceptance tests first** — dispatch an **acceptance test author** (spec
   only, never the implementation). Show the suite failing for the right reason
   — missing behavior, not syntax. The user reviews them; they are the spec now.
   Then **lock them** — the implementer's package forbids test paths, and
   CODEOWNERS guards the human side.
4. **Implement** — dispatch an **implementer** with the locked tests, the spec,
   and the ADR constraints. All gates green after each logical step; the
   implementer may not touch tests or exceed scope.
5. **Independent review** — dispatch a **reviewer** (fresh context; spec + diff
   + results, never the implementer's reasoning). For each criterion: is there a
   test that would fail if it broke, and does the implementation satisfy it or
   only the test? Then run `code-review` (quality + the red-team trio) as a
   second fresh pass.
6. **Close out** — dispatch a **spec reconciler** to update the spec and
   `decisions.md` to match what was built. Update the slice task and the GitHub
   progress.
7. **Clean up when the *effort* completes** — not per slice. The vault
   scratchpad (`planning/<slug>/`, incl. its `specs/`) is **transient**:
   consolidate durable insights into the wiki/memory, then move it to `.trash/`
   (recoverable). A finished effort leaves no working files behind.

## Gates

Every step ends green: typecheck, lint, format:check, tests, build, boundary
gate. "Done" = gates green **and** the independent review passed.

## Outputs

- repo: code + tests
- vault: updated spec, decisions, open questions
- GitHub: slice issue/PR progress

## Exit criteria

- All gates green; the reviewer found no blocking gap; the spec matches reality.

## Must not

- Skip the spec-delta check.
- Let the implementer touch tests.
- Accept a worker's "done" without evidence.
- Merge red.

## Related

- **Loads:** `agent-delegation`, `code-review`, `git-workflow`.
- **References:** `software-development`, `software-testing`, `spec-change`.
