---
name: premise-demolition
description: Scrutinise an existing system against its spec with fresh eyes and produce a demolition-first refactor — the spec is the only input, the implementation is a claim, and every element must earn its place against a user story or acceptance criterion. Use when asked to reflect on or refactor an existing system, when a design feels over-engineered, when someone says "this is too complex" or "is this even right?", or before any re-architecture.
---

# premise-demolition

The procedure for judging an existing system and rebuilding it lean. Ruthless by
design: the default is deletion, and the burden of proof is on keeping.

This is not alignment. Alignment asks "does the code match the contract?" —
which takes the code, and the contract's shape, as given. This asks the prior
question: **what should exist at all?** Alignment is the trap that produces
file-shuffling; demolition produces a smaller system.

## Related

- **Loads:** `systems-thinking` (the lens — this procedure is its application).
- **References:** `software-architecture` (the lean guardrail and the house
  contract), `feature-spec` (the spec that is the only input), `code-review`
  (the findings format), `slice-delivery` (delivering the resulting refactor),
  `git-workflow`, `agent-delegation` (the premise-auditor role).

## When to use

- "Reflect on this", "refactor this", "scrutinise this", "re-architect this".
- "This is too complex", "is this even right?", "does this make sense?".
- Before any large refactor — to decide what should survive it.

## The prime directive

**The spec is the only input. The implementation is a claim.**

The user stories and their acceptance criteria define the essential. The current
code, its `ARCHITECTURE.md`, its ADRs, and any prior plan are *claims to test*,
never constraints to honour. Forget them as givens.

## Delegate the scrutiny — never do it in the anchored context

The orchestrator is the most anchored reader in the room: it has read the prior
plans, the ADRs, and the existing `ARCHITECTURE.md`, and it adopted their
framing. Fresh eyes are not a mood you can adopt; they are a property of
withheld context.

So the scrutiny is dispatched to a **premise auditor** — a fresh-context worker
that receives the spec and the source, and *not* the prior plans, the ADRs'
conclusions, or the orchestrator's framing (see `agent-delegation`). The
orchestrator verifies the evidence and owns the decision; it does not perform
the audit itself.

## Steps

1. **Fresh eyes.** Read only the spec. State the system in one breath
   (`systems-thinking`). Do not open the tree first.
2. **Derive the picture of good.** From the spec alone, the essential model —
   the concepts, the external systems, the flows, the invariants. This is the
   target, derived, not copied.
3. **Read the existing design as a hypothesis.** Now read the code and its
   justifications. Every "why X is what it is" is a hypothesis to falsify. A
   fluent defence is a warning sign: the more articulate the justification for
   a structure, the more it deserves testing, because the justification is
   usually written after the fact.
4. **The demolition list.** For each element, ask: which spec rule requires
   this? If none, it is accidental complexity. **The burden of proof is on
   keeping, not deleting.**
5. **The rebuild plan.** The lean shape that satisfies the spec — usually
   smaller than the demolition list, because deletions cascade.

## Ruthlessness rules

- Default to deletion. "It might be useful later" is not a reason; a real spec
  rule is.
- A past decision is not a constraint unless the spec depends on it. ADRs are
  decisions, not physics.
- "It works" is not "it's right". Working code can be the wrong system.
- Do not preserve an element to avoid churn. Churn is the cost of a wrong
  shape; paying it once is cheaper than carrying the shape forever.
- Apply the lean guardrail at the **design** level, not per file. The failure
  mode is to scrutinise each file and never question the framework the files
  serve.

## Anti-anchoring (failure modes we have observed)

- Starting from the current tree and re-arranging it. Grouping is not fixing.
- Adopting the existing vocabulary — it carries the old design's assumptions.
- Treating a prior plan's scope ("structure and naming only", "no behaviour
  change") as given. That scope was a choice, not a constraint.
- Reading a repo's own `ARCHITECTURE.md` as authoritative. It is the design
  defending itself; read it last, and sceptically.

## Output — the premise audit

- **The one-breath statement.**
- **The essential model** (derived from the spec).
- **The demolition list** — per entry: the element · the spec rule it fails ·
  the rule it violates (lean guardrail, Rule of Three, ISP, …).
- **The rebuild plan** — the lean shape, in the house contract's terms.

Each finding in the `code-review` output shape: severity · location · what's
wrong · the fix. Design-level, not line-level.

## Must not

- Align the code to the contract without first asking whether the contract's
  shape fits *this* product.
- Shuffle or group files as the fix.
- Accept the existing architecture document, ADRs, or prior plans as ground
  truth.
- Perform the audit in the orchestrator's anchored context instead of
  delegating it.
