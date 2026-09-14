---
name: edge-case-analysis
description: Adversarial analysis of unhandled code paths and robustness — boundary values, null/empty/undefined, type coercion, race conditions, resource exhaustion, state-machine violations, and error handling. Use when reviewing code for edge cases, crashes, hangs, and denial-of-service, or as the robustness step of a red-team review.
---

# edge-case-analysis

The adversarial pass for unhandled code paths and robustness. Where `security-review` hunts vulnerability classes, this hunts the boundary conditions, concurrency, and error paths that crash, hang, or exhaust the system — many of which are also security issues (DoS, TOCTOU).

## When to use

- Reviewing code for edge cases, crashes, hangs, and resource exhaustion.
- The robustness step of a red-team review (with `threat-modeling` and `security-review`).
- Reviewing parsers, protocol handlers, state machines, or anything that consumes untrusted input.

## Attack vectors

Probe each systematically:

1. **Boundary values** — zero, MAX_INT, empty, just below/at/above limits, year 9999, oversized fields.
2. **Null / missing / undefined** — missing fields, nested nulls, optional fields, empty collections.
3. **Type coercion** — string where number expected, null vs undefined vs "", `as` casts, `any` propagation.
4. **Race conditions / TOCTOU** — check-then-act, double-submit, concurrent mutations, stale closures, non-atomic updates.
5. **Resource exhaustion / DoS** — regex DoS, decompression bombs, unbounded loops/allocations, missing timeouts/rate limits, stack overflow.
6. **State-machine violations** — skipped states, invalid transitions, out-of-sequence operations, orphaned states.
7. **Error handling** — unhandled exceptions, failing open, swallowed errors, unstable states after failure.
8. **Encoding** — UTF-8 BOM, null bytes, emoji, RTL, homoglyphs, double-encoding.
9. **API contracts** — extra fields, missing auth, pagination edge cases, malformed input.

## Method

- **Recon** the input points, state transitions, and external dependencies.
- **Probe** each attack vector against each surface, adversarially.
- **Reproduce** — for each finding, produce a concrete trigger (a failing test or input) that demonstrates it.
- **Triage** by severity (CRITICAL/HIGH/MEDIUM/LOW) and reachability.
- **Report** findings with severity, location, what's wrong, the fix, and the reproducer.

## Contract

- Every finding has a **concrete trigger** — an input or interleaving that reproduces it. A finding without a reproducer is flagged as theoretical.
- Distinguish **reachable** (an attacker or user can trigger it) from **unreachable** (defensive only).
- Report as **blocking** or **non-blocking**.
- Adversarial framing only.

## Related

- **Loads:** (none)
- **References:** `security-review` (vulnerability classes), `threat-modeling` (scope), `code-review` (the review it feeds)
