---
name: discovery-interview
description: Interview-first discovery for a project or feature — ask, don't assume; resolve what we know, track what we don't. Offers concrete options with a recommended default, records decisions, and routes unknowns to the open-questions register. Folds in event storming as a structuring technique for complex domains. Use when a brief is vague, when starting discovery, or when the user hands over raw material and says "figure out what we're building".
---

# discovery-interview

Phase 2. The output is a brief, a decision log, and a register of open
questions — not a design, not code.

## When to use

- A vague brief, raw material, or "figure out what we're building".
- Starting discovery on a project or a large feature.

## Inputs

- The raw material the user provides.
- `planning/<slug>/brief.md`, `decisions.md`, `open-questions.md`.

## Interview rules

1. **At most 5 questions per round**, most important first.
2. **Order by cost to reverse** — data model, rules engine, who can do what
   before UI details.
3. **Offer 2–3 concrete options with a recommended default and why.** The user
   answers "A", "B", or free text.
4. **Don't ask what the material already answers** — state it as an assumption
   for the user to confirm.
5. **"I don't know" is a valid answer.** It becomes an open question with an
   owner and a BLOCKING or DEFERRABLE status.
6. After each round, update `decisions.md` (what was decided) and
   `open-questions.md` (what is still unknown).

## Event storming (when the domain needs structuring)

For a complex domain — many events, rules, or actors — reach for the technique
in `references/event-storming.md`: enumerate events, commands, actors, and
policies, group them into bounded contexts, and surface the hotspots. It is most
useful as we approach implementation, where aggregates and rules get concrete.
Run it with the user, not for them.

## Client mode

When the answers live with someone else — a client, a colleague, a relative —
the questions must be phrased for a non-technical stakeholder. See
`references/client-discovery.md`. When the user is their own client, answer
in-conversation and skip the client framing.

## Wrap-up

Synthesize into `brief.md`: problem, user roles, goals, explicit non-goals, key
constraints. Then list every remaining BLOCKING open question. Resolve none of
them yourself.

## Delegating

- A **material analyst** extracts facts / inferences / unknowns and proposes the
  questions; the orchestrator asks them.

## Outputs

- `brief.md` (problem, roles, goals, non-goals, constraints)
- updated `decisions.md`, `open-questions.md`

## Exit criteria

- The brief is written and the user has confirmed it.
- Every unknown is a tracked open question with an owner and a status.

## Must not

- Design the solution, choose a stack, or write code.
- Resolve an unknown by guessing.

## Related

- **Loads:** `agent-delegation`.
- **References:** `shape-up` (framing), `software-architecture` (domain
  concepts), `vault-notes`.
