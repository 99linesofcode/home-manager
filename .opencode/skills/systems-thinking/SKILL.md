---
name: systems-thinking
description: The lens for seeing a system as a whole before judging or changing any part of it — state the system in one breath, separate essential from accidental complexity, right-size the design to the real system, and derive the picture of what good looks like from the spec alone. Use when modelling a system, when asked whether a design is right, when a design feels too complex, or as the first move of a re-architecture (with premise-demolition).
metadata:
  category: analysis
  route-when: "Use when modelling a system or feature for the first time, when asked whether a design is right, or as the first move of a re-architecture."
  route-not-when: "Use `premise-demolition` for the demolition-first refactor itself, once the picture of what good looks like is formed."
---

# systems-thinking

The lens. You cannot judge a part without the whole it serves. This skill is the
contract for forming that whole — the picture of what good looks like — before
you design, change, or criticise anything.

## Related

- **Loads:** (none — a lens, loaded on demand).
- **References:** `software-architecture` (the house design contract),
  `discovery-interview` (framing a new system), `architecture-and-skeleton`
  (choosing a shape), `premise-demolition` (the scrutiny procedure that loads
  this).

## When to use

- Modelling a system or a feature for the first time.
- Asked "is this the right design?", "does this make sense?", "why is this so
  complex?".
- Before any re-architecture or large refactor — as step 1 of
  `premise-demolition`.

## The core moves

1. **State the system in one breath.** One or two sentences: what it takes in,
   what it produces, who consumes it, what state it must keep, what it must
   never do. If you cannot, you do not understand it yet — and *that* is the
   first finding, not a reason to keep reading code.

   > "It mirrors a vault's projects and tasks onto external tools, keeping the
   > vault authoritative and the tools honest." That is a system. If the
   > sentence needs a paragraph of machinery to be true, the machinery is the
   > finding.

2. **Separate essential from accidental complexity.** Essential complexity is
   what the *spec* requires — the user stories and their acceptance criteria,
   nothing more. Accidental complexity is everything the solution introduced:
   the framework, the registry, the layer, the abstraction. Name which is
   which. Accidental complexity is the target.

3. **Right-size to the real system.** Design for the number of *real*
   instances, not the possible ones. Two providers are two adapters; a third is
   a new adapter, not a framework. The Rule of Three is a trigger to *unify a
   shape*, never a licence to build the general case.

   > Two task managers and one code host do not need a capability-descriptor
   > registry. They need two adapters and one canonical shape. The registry
   > serves a system with N unknown providers; this system has three known ones.

4. **Find the boundary, the flows, the state, the feedback.** What enters, what
   leaves, what must survive a restart, and what corrects drift. An element
   that serves none of the four is accidental by definition.

5. **Find the leverage.** The smallest change that removes the most complexity
   — usually a deletion high in the dependency chain, rarely a refactor low in
   it. Deleting a registrar removes the capability vocabulary, the validation,
   and every adapter's descriptor at once.

6. **Derive the picture of good — from the spec alone.** Ask: what would this
   be if it were built today by someone who never saw the current code? That
   derived picture is the standard. The existing design is judged against it;
   the existing design is never the starting point.

## The one-breath test

If the existing design cannot be derived from the one-breath statement and the
spec, the gap between them *is* the finding. You do not need to hunt for
problems: state the system, derive the design it implies, and diff.

## Output

- The one-breath statement.
- The essential model — the concepts, external systems, flows, and invariants
  the spec requires.
- The accidental-complexity list — every element that serves no spec rule.
- The derived picture of good — the shape you would build today.

## Must not

- Start from the current implementation or adopt its vocabulary.
- Produce a diagram for its own sake — the statement is the artefact.
- Restate textbook systems thinking; this is the *contract*, not the theory.
- Treat "it exists" or "it works" as evidence an element belongs.
