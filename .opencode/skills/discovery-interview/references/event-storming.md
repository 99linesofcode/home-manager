# Event storming — the technique

A structuring technique for a complex domain, run with the user. The point is to
surface what the domain *does* (events), what causes it (commands), who does it
(actors), and what reacts to it (policies) — then find the boundaries and the
things we don't agree on.

## The elements

- **Domain event** — something that happened, past tense, business-meaningful
  ("ShiftAssigned", "SwapRequested", "AvailabilitySubmitted"). Events are the
  spine.
- **Command** — the intent that triggers an event ("AssignShift",
  "RequestSwap").
- **Actor** — who issues the command (nurse, manager, scheduler, system).
- **Policy** — "whenever <event>, then <command>" ("whenever a swap is
  requested, notify the receiving manager").
- **Read model** — what a screen or report needs to show.
- **Aggregate** — the consistency boundary: the cluster of events/commands that
  must stay consistent together (a Shift, a SwapRequest).
- **Bounded context** — where one model's terms apply (Scheduling, Availability,
  Notifications). The same word can mean different things across contexts.
- **Hotspot** — a disagreement, ambiguity, or gap. These are the output that
  matters most.

## The flow

1. **Chaotic exploration** — dump every event, no order, in the user's words.
2. **Timeline** — order the events along the happy path.
3. **Add commands, actors, policies** — who causes what, what reacts to what.
4. **Group into aggregates and bounded contexts** — draw the consistency and
   language boundaries.
5. **Mark hotspots** — every "we're not sure", "it depends", "who decides?".

## Output

- A domain model: bounded contexts, aggregates, and command→event flows.
- A **hotspots list** — each one becomes an open question (owner +
  BLOCKING/DEFERRABLE) or an interview question.

## Rules

- Business language only — no tables, no endpoints, no classes.
- One bounded context at a time; don't merge contexts to make it tidy.
- Every hotspot is captured, never resolved in the room by guessing.
