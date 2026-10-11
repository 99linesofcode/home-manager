---
name: spec-change
description: Handle changed intent or newly discovered ambiguity mid-build by producing an approved spec delta — affected rules, invalidated tests, affected slices — before touching any code. Use when the user changes their mind, a requirement shifts, or implementation surfaces an ambiguity the spec does not cover.
metadata:
  category: delivery
  route-when: "Use when the user changes their mind mid-build, when a requirement shifts, or when implementation surfaces an ambiguity the spec does not cover."
  route-not-when: "Do not use to author a new spec from scratch — that is `feature-spec`."
---

# spec-change

Phase 7. The order is always spec → tests → code, even for a change you're sure
about.

## Related

- **Loads:** `agent-delegation`.
- **References:** `feature-spec`, `slice-delivery`.

## When to use

- The user changes their mind about behavior.
- Implementation surfaces ambiguity the spec doesn't cover.
- A discovered unknown invalidates part of a spec.

## Inputs

- The affected spec, `decisions.md`, the slice tasks.

## Steps

1. **Do not touch code yet.** Produce the spec delta using the template at
   `~/.config/opencode/skills/slice-delivery/assets/spec-delta.template.md`:
   - which rules and scenarios change, are added, or are removed
   - which existing tests become invalid, and why
   - which merged slices are affected
   - a proposed re-slicing of the remaining work
2. **Get the user's approval** of the delta.
3. **Update specs and tests first**, then implementation — never the reverse.
4. **Record the decision** in `decisions.md`; update the affected slice tasks
   and GitHub issues.

## Delegating

- **spec writer** (the delta), **spec adversary** (attack it before approval).

## Outputs

- updated spec(s), invalidated/updated tests, `decisions.md`, re-sliced tasks.

## Exit criteria

- The delta is approved and the spec, tests, and code agree again.

## Must not

- Change code before the delta is approved.
- Resolve a newly discovered ambiguity by choosing.

