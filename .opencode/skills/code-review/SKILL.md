---
name: code-review
description: The user's code review contract — what a review must check, structured so a worker can run it automated. Covers atomicity, correctness, self-documenting code, no dangling code, tests, architecture adherence, and security. Manual for now; designed to be run by a separate worker. Use when reviewing a pull request or change, or when preparing a change for review.
---

# code-review

The user's standard for what a code review must check. Reviews are **manual for
now** (human-in-the-loop), but this contract is written so a separate worker can
run it automated later. Everything needed to make a review frictionless should
be in place.

## When to use

- Reviewing a pull request or change.
- Preparing a change for review (run the checklist against your own diff first).
- The user references review, PR review, or "is this ready to merge."

## The review checklist

A review checks the change against the user's standards. Work through each:

### 1. Atomicity (one concern)

- Does the change do one thing? One feature, one fix, one refactor?
- Does the diff contain only this change's concern, or unrelated edits?
- If it mixes concerns, it should be split.

### 2. Correctness

- Does the change work? Does it do what the ticket/issue says?
- Are edge cases handled (empty input, nulls, boundary values)?
- Does it verify (tests, typecheck, build, lint pass)?

### 3. Self-documenting code

- Are names clear? Does the code read without comments?
- Do comments explain WHY, not WHAT? (see `self-documenting-code`)
- Is the code step-down ordered and reasonably sized?

### 4. No dangling code (cleanup-as-you-go)

- Did the change remove dead code it superseded?
- Any unused functions, imports, parameters, or branches left behind?
- Any dangling references to renamed/removed symbols?
- Do docs/README match the new behavior?

### 5. Tests

- Does the change ship tests for the behavior it adds or changes?
- Do the tests follow the Given/When/Then contract? (see `software-testing`)
- Do they assert on behavior and state, not implementation?

### 6. Architecture adherence

- Does the change follow the layering? (see `software-architecture`)
- Does the UI reach the domain only through actions + DTOs?
- Any layering violations (domain importing UI, UI calling Eloquent directly)?
- Does it follow the lean guardrail (no speculative abstraction)?

### 7. Red team / adversarial review (mandatory)

Run the red-team suite against the change. This is not optional — every review
attacks the code before it merges. Load and apply all three:

- **`threat-modeling`** — model the change: assets, trust boundaries, data
  flows, STRIDE threats. Scopes what to attack.
- **`security-review`** — hunt vulnerability classes (access control, injection,
  crypto, auth, supply chain) and validate exploitability. Evidence-grounded
  findings (file:line + exploit path).
- **`edge-case-analysis`** — unhandled code paths: boundaries, null/undefined,
  race conditions/TOCTOU, resource exhaustion/DoS, state-machine violations,
  error handling.

Every finding is a hypothesis until verified. Report blocking vs non-blocking,
with a concrete fix. Secrets/keys/`.env` in the diff are always blocking.

### 8. Commit hygiene

- Conventional Commit message that states the final state?
- History squashed by feature before push? (see `git-workflow`)

## How to run a review

1. Read the diff (`git diff` / PR files).
2. Run the project's checks (tests, typecheck, build, lint).
3. Grep for dangling references to renamed/removed symbols.
4. Work through the checklist above.
5. Report findings as: blocking (must fix before merge) vs. non-blocking
   (suggestions). Be specific — name the file, the line, the fix.

## Output contract

A review reports, for each finding:

- **Severity** — blocking or non-blocking.
- **Location** — file + line.
- **What's wrong** — the specific issue.
- **The fix** — the concrete change.

Blocking findings must be resolved before merge. Non-blocking findings are
suggestions the author may take or leave.

## Related

- **Loads:** `threat-modeling`, `security-review`, `edge-case-analysis` (the
  mandatory red-team step)
- **References:** `software-development` (atomicity, cleanup, done),
  `self-documenting-code` (the style contract), `software-testing` (the test
  contract), `software-architecture` (the layering), `git-workflow` (commit
  hygiene).
