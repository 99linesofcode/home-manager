---
name: ddd-implementation-elicitation
description: Before writing code for an approved slice or a relatively large feature, spar with the user one question at a time to pin down the decisions that are expensive to unwind later — architecture fit, public interfaces and data contracts, non-functional constraints, explicit non-goals, and test expectations — rather than either guessing silently or dumping a long requirements form on them. This is stage 4, the final stage, of a four-stage DDD discovery pipeline (event storming structuring → discovery questions → slice planning → this stage), normally run right before implementation begins on a signed-off slice. Also trigger standalone on any relatively large or multi-step software development task the user wants planned before coding starts, even without prior DDD stages — phrases like "build me a system for X", "I need to implement Y", or "help me plan how to build Z" for anything beyond a small, contained change.
---

# Implementation Elicitation

## Where this sits

Stage 4, the last stage, of the discovery pipeline: `ddd-event-storming-to-domain-model` → `ddd-discovery-questions` → `ddd-slice-planning` → **this skill**. If a domain model or slice definition exists from earlier stages, use its vocabulary (aggregate and context names, the slice's stated scope) rather than re-deriving the feature from scratch — that continuity is half the value of running the earlier stages at all. This skill also stands on its own for any substantial build task that didn't go through the full pipeline. When wayfinder orchestrates the build, this runs before each slice's implementation package is composed — the recap from step 5 is what the package is built from.

## The core judgment call

Not every implementation detail deserves a question. The test that matters: **if a wrong guess here would ripple into other modules, other contexts, or would be expensive to change once code exists, ask about it. If a wrong guess is local and easy to correct, let the user skip it and move on** — or don't ask at all if it's genuinely a local implementation detail.

Worth pinning down before code:
- Architecture or pattern to follow — an existing convention in the codebase, or a deliberate choice for this feature
- Public interfaces, data models, or schemas that other parts of the system (or other teams) will depend on
- Non-functional constraints: performance targets, security requirements, backward compatibility
- Explicit non-goals — what's deliberately out of scope, so it doesn't get silently added or silently assumed
- How the user wants this verified — tests, manual QA, acceptance criteria

Safe to leave open, and shouldn't be asked about:
- Internal helper structure, local variable/function naming, order of operations within a function
- Anything reversible without touching other files

## How to run it

1. **Frame it briefly.** One or two sentences on why this conversation happens before code, not instead of a full spec — the goal is to remove the expensive-to-reverse unknowns, not to interrogate every detail.

2. **One question at a time, and wait for the answer.** Don't front-load a checklist. Sparring works because each answer can change what's worth asking next — a monolith and a set of independent services need different questions about interfaces, for instance. Let the conversation adapt.

3. **Explain why a question matters when you first raise it**, briefly — "asking because this becomes the contract other services call, so it's costly to change after they integrate against it" — rather than asking cold. This is also how the user builds their own intuition for the ripple-vs-local test over time, instead of having to trust your judgment forever.

4. **If the request is ambiguous or underspecified in a low-stakes way, don't stop to ask** — state the assumption you're making and move on. Reserve actual questions for the things that would be costly to get wrong.

5. **When the important unknowns are resolved, recap what's been pinned down** in a short list, confirm the user is ready, and proceed straight into the implementation using that recap as the working spec. This stage doesn't produce a saved file of its own — the sign-off doc from `ddd-slice-planning` (if it exists) is the durable record; this conversation's job is to get the remaining decisions settled, not to generate another document.

## Related

- **Loads:** (none — pipeline stages are invoked separately by the user)
- **References:** `ddd-slice-planning` (upstream sign-off doc), `software-architecture` (architecture conventions the pinned decisions should follow), `software-development` (the gate governing the build that follows)
