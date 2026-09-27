---
name: ddd-event-storming-to-domain-model
description: Turn raw event storming session output (sticky notes, photos, a rough list of events/commands/actors, or a messy transcript) into a structured domain model — bounded contexts, aggregates, command-to-event flows, and an explicit list of hotspots. This is stage 1 of a four-stage DDD discovery pipeline (structuring → discovery questions → slice planning → implementation elicitation). Use this whenever the user mentions event storming, sticky notes or photos from a modeling workshop, a client working session on domain modeling, or asks to organize/structure what came out of such a session. Also trigger on a rough, unstructured description of a business process or domain that the user wants turned into aggregates and bounded contexts, even if they never say "event storming."
---

# Event Storming → Domain Model

## Where this sits

This is stage 1 of a discovery pipeline for large software projects:

1. **This skill** — structure raw event storming output into a domain model
2. `ddd-discovery-questions` — turn the hotspots this stage surfaces into client-ready questions
3. `ddd-slice-planning` — turn a settled model into a build plan and a sign-off doc
4. `ddd-implementation-elicitation` — pin down implementation decisions before code, per slice

Each stage is invoked separately by the user. Nothing here gets saved to a file automatically — the pipeline's only saved deliverable is the sign-off doc produced at the end of stage 3. So close this stage with a copyable summary (see Output below) the user can paste into the next conversation if they aren't continuing in the same thread.

## Why this stage matters

Event storming produces a pile of color-coded facts, not a model. Two things tend to get lost if nobody structures the output: the actual aggregate boundaries (which sticky notes belong together, and where the consistency boundaries are), and the disagreements or "we don't know" moments the group glossed over to keep the workshop moving. This stage exists to catch both before they turn into rework later.

## How to run it

1. **Get the raw input.** Ask for it if it's not already in the conversation — photos of the board, a list of sticky notes, or a loose narrative description of the process. If it's photos, look at them directly rather than asking the user to transcribe.

2. **Frame the goal in one or two sentences before starting**, so the user knows what shape you're building toward: bounded contexts, aggregates with their commands and events, actors/policies, and an explicit hotspot list.

3. **Work one grouping decision at a time.** Propose one cluster of events as a candidate aggregate, or one candidate bounded context boundary, and wait for the user to confirm or correct it before moving to the next. Don't produce the whole model in one shot and ask "does this look right?" — by the time the user reads a full model, early mistakes have already propagated into later groupings, and it's harder for them to spot what to push back on. Small, sequential proposals are easier to correct.

4. **Teach the vocabulary as it comes up, not up front.** The first time you introduce a term the user hasn't used themselves (aggregate, bounded context, policy, invariant), give a one- or two-sentence plain-language explanation tied to the example in front of you, not an abstract definition. Skip the explanation if the user is clearly already fluent (they're the one using the terms).

5. **Don't resolve disagreements — collect them.** If the group's notes show conflicting views, an unclear owner for a command, or a "we weren't sure" moment, do not silently pick an interpretation. Name it explicitly as a hotspot and move on. Resolving these is stage 2's job, with the client in the loop — deciding here on the user's behalf would just relocate the ambiguity instead of removing it.

## What to build

For each bounded context:
- A one-line description of what it's responsible for
- Its aggregates, each with: the commands it accepts, the events it emits, and any invariant that's already clear ("a Reservation can't be confirmed without payment captured")
- The actors and policies that connect things (who/what triggers a reaction, and what it triggers)

Across the whole model:
- A hotspot list: each entry names what's uncertain, which sticky notes or moment in the session it came from, and — where visible — what downstream decision depends on resolving it

## Example

Raw notes: "customer books table", "system sends confirmation", "no-show
after 15 min releases the table", "staff can override a booking". One
candidate aggregate, proposed one at a time: **Reservation** — commands
`BookTable`, `MarkNoShow`, `StaffOverride`; events `TableBooked`,
`ConfirmationSent`, `TableReleased`; invariant: a table cannot be
double-booked. Open grouping question (a hotspot, not a decision): does
Reservation own the notification, or does a separate notification policy
react to `TableBooked`?

## Output

End the stage with:
- The structured model as above, presented as normal chat content (not a saved file)
- The hotspot list, clearly separated, since it's the direct input to stage 2
- A short "carry forward" block the user can copy into a new conversation to start `ddd-discovery-questions` or continue later
- One line pointing at the next stage: that hotspots are ready to become client-facing questions via `ddd-discovery-questions`

## Related

- **Loads:** (none — pipeline stages are invoked separately by the user)
- **References:** `ddd-discovery-questions`, `ddd-slice-planning`, `ddd-implementation-elicitation` (the downstream stages)
