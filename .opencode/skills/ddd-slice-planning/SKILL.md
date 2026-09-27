---
name: ddd-slice-planning
description: Turn a settled domain model into a build plan — bounded-context dependencies, a candidate first thin vertical slice, and a rough order for what follows — then compile the one saved deliverable in the discovery pipeline — a sign-off design doc (model summary, resolved decisions, remaining assumptions, first slice) for client review before any code is written. This is stage 3 of a four-stage DDD discovery pipeline (event storming structuring → discovery questions → this stage → implementation elicitation). Trigger when the user's domain model is stable and they want to decide what to build first, plan phases or milestones, or need a design doc to get sign-off before development starts.
---

# Domain Model → Slice Plan & Sign-off Doc

## Where this sits

Stage 3 of the discovery pipeline: `ddd-event-storming-to-domain-model` → `ddd-discovery-questions` → **this skill** → `ddd-implementation-elicitation`. This is the only stage that saves a file — everything upstream stays conversational, but the output here is meant to leave the pipeline and go in front of the client, so it earns a real document.

## Why this stage matters

A domain model tells you what the system is; it doesn't tell you what to build first. Building breadth-first by technical layer (all the database tables, then all the APIs, then all the UI) defers the riskiest questions — does the model actually hold together end to end — until everything is already built. A thin vertical slice does the opposite: it picks one real user journey and takes it all the way through one bounded context, so the model gets stress-tested early, while it's still cheap to adjust.

## How to run it

1. **Confirm the model is available.** Use what's already in the conversation from earlier stages, or ask the user to paste/summarize it if this is a fresh session.

2. **Work one decision at a time, Socratically:**
   - Map which bounded contexts depend on which. This alone often reorders what "first" should mean.
   - Check the user's intuition for "thin vertical slice" against the actual definition — one user journey, end to end, through one context — and correct gently if what they're picturing is really a technical layer or a partial feature.
   - Propose slice candidates one at a time rather than listing several for the user to rank. For each candidate, surface the trade-off explicitly: business value delivered vs. technical/model risk retired vs. how many other contexts it drags in.
   - Converge on a first slice, then a rough, low-confidence order for what comes after it — this second part doesn't need the same rigor, it's a roadmap sketch, not a commitment.

3. **Explain the reasoning as you go**, especially if the user's first instinct is to start with the easiest feature rather than the riskiest unknown. Starting with the part of the model you're least sure about — rather than the part that's easiest to build — is often the better trade, because it surfaces a wrong assumption while it's still one slice's worth of work to fix, not five. The user is learning slice reasoning — name the trade-off behind each call (value delivered vs. risk retired vs. contexts dragged in) so they build the intuition, not just the plan.

## The sign-off doc

Once a first slice is settled, compile the document that gets client sign-off before any code is written. It should contain:

- **Model summary** — bounded contexts and their aggregates, in plain language, not raw event-storming notation
- **Resolved decisions** — the discovery questions that came back answered, and what was decided
- **Remaining assumptions** — anything still unanswered that you're proceeding on anyway, stated explicitly so the client can object if a guess is wrong
- **First slice** — the user journey, the context(s) it touches, and what "done" looks like for it
- **Rough roadmap** — the tentative order of what follows, flagged as subject to change

A minimal sign-off doc in shape:

> **Model summary** — Booking (reservations, no-show release) and Notification (confirmation emails), one context each.
> **Resolved decisions** — returning customers match by email (client answer).
> **Remaining assumptions** — no-show grace period fixed at 15 minutes; the client can still object.
> **First slice** — a customer books a table end to end and receives confirmation. Done = the journey works in the browser against real data.
> **Rough roadmap** — staff overrides, then no-show automation. Subject to change.

Default to a clean Markdown document — it's fast to produce and easy for the client to read or comment on. If the user signals this needs to look like a formal deliverable (e.g. "I need to send this to the client" in a business context, or they explicitly ask for a formal document), use the `typst-document` skill instead and follow its guidance rather than hand-rolling formatting.

Save the file, then present it to the user rather than pasting the whole document into the chat — it's meant to leave the conversation. When wayfinder orchestrates the work, save it as `planning/<slug>/signoff.md`; otherwise ask where the user keeps client documents — it's a client deliverable, not a repo artifact.

## Closing

Point to `ddd-implementation-elicitation` as the next stage, to be run once the client has signed off and the user is about to start building the first slice.

## Related

- **Loads:** (none — pipeline stages are invoked separately by the user)
- **References:** `ddd-discovery-questions` (upstream), `ddd-implementation-elicitation` (next stage), `typst-document` (formal client-facing deliverables)
