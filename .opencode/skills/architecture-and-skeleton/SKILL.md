---
name: architecture-and-skeleton
description: Propose 2-3 architecture/stack options with trade-offs and a recommendation, record the decision as an ADR, run time-boxed spikes for the risky unknowns, then build the walking skeleton — one thin end-to-end path with CI and mechanical boundary enforcement. Use when choosing a stack or architecture, when "how should we structure this" comes up, or before any real feature is built.
---

# architecture-and-skeleton

Phase 4. Propose, decide, spike the risky parts, then prove the shape with a
walking skeleton.

## When to use

- Choosing a stack or architecture for a project.
- "How should we structure this."
- Before the first real feature — the skeleton comes first.

## Inputs

- `brief.md`, the specs, `decisions.md`.

## Steps

1. **Options, not a decree.** Dispatch an **options analyst**: 2–3 viable options
   with trade-offs for *this* project, one recommendation, and the parts that
   are risky or poorly understood. Wait for the user's decision.
2. **Record the ADR** in `docs/architecture/NNN-<slug>.md` from
   `assets/adr.template.md`. The rationale lives in the ADR; the *enforceable*
   part becomes a test or a boundary gate.
3. **Spike the unknowns.** For each risky open question, dispatch a **spike
   engineer** for a time-boxed throwaway prototype in `spikes/`. Nothing
   graduates without a fresh implementation.
4. **Build the walking skeleton.** Dispatch an **implementer** with a skeleton
   brief: one HTTP endpoint, one DB table, one UI page, one acceptance test, CI
   running every gate, and the boundary rules from the ADR enforced
   mechanically. No real features — the goal is a green pipeline every later
   slice plugs into.
5. **Fill in `ARCHITECTURE.md`** — modules, boundaries, flows (mermaid),
   conventions, invariants. This is where a new agent or developer finds their
   way around the codebase.

## Delegating

- **options analyst**, **spike engineer**, **implementer** (skeleton brief).

## Outputs

- `docs/architecture/NNN-*.md` (ADRs)
- `spikes/` (throwaway)
- the walking skeleton + CI + boundary gate
- filled `ARCHITECTURE.md`

## Exit criteria

- The ADR is written and the user approved the choice.
- CI runs all gates green on the skeleton.
- The boundary rules are mechanically enforced — a violating change fails.
- `ARCHITECTURE.md` reflects the built shape.

## Must not

- Build real features.
- Let a spike's code graduate into the main tree.
- Choose the architecture for the user.

## Related

- **Loads:** `agent-delegation`.
- **References:** `software-architecture`, `new-project`, `software-development`.
