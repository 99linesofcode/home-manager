---
name: memory
description: Two-tier file-native memory system (working + episodic/semantic with threshold-triggered reflection), grounded in Generative Agents and Files-as-Memory research. Emits OKF v0.2-conformant concepts.
license: MIT
---

# Memory

Two-tier, file-native memory. Working memory is always injected; the episodic
stream is appended and retrieved; semantic memory is consolidated on reflection.

Every persistent memory document is an **OKF v0.2 concept**: YAML frontmatter
with a non-empty `type`, plus the `generated` / `verified` / `status` /
`stale_after` families where applicable. `importance` and `evidence` are our
producer extensions (OKF preserves unknown keys).

This is file-native by design. For a single-user knowledge base up to roughly
2,000 hand-authored memories, typed markdown + `index.md` + grep is the correct
tool. A vector DB / SQLite is only warranted for a large *external* corpus,
and would then be a separate MCP layer beside this, not a replacement.

## Load order (startup)

1. `memory/HOT.md` (working, ≤2000 tokens)
2. `memory/semantic/user.md`
3. `memory/semantic/decisions.md`
4. tail of `wiki/log.md`

## Working (`HOT.md`)

Operational scratch, not an OKF concept. Always-injected bootstrap. Structure:

```
# Working Memory — <date>
## Current focus   (one sentence)
## Open loops      (bullets)
## Last decisions  (bullets, with date)
## Next action     (one bullet)
## Handoff         (only when pre-compaction; highest-value item)
```

Hard cap 2000 tokens. Discard order when over budget: richest detail first;
keep `Handoff` and `Next action` last.

### Milestones (when `HOT.md` is rewritten)

A **milestone** is a natural, observable point where state has meaningfully
changed. It triggers a `HOT.md` rewrite **and** a reflection-threshold check.
A milestone is any of, whichever comes first:

1. A unit of work reaches "done" (a triage class-2/3 task completes).
2. An open loop is closed or a decision is recorded.
3. A Wayfinder phase transition occurs (interview → map → resolve → spec → promote).
4. Fallback: 5+ episodic events written since the last milestone, or ~30 min of
   active work.

"Session end" and "before compaction" are additional rewrite triggers, but they
are not reliably signaled by the harness — treat the explicit milestone criteria
above as the dependable cadence, and the "consolidate memory" command as the
deterministic reflection trigger.

## Episodic stream (OKF concepts)

Every meaningful event → one file `memory/episodic/stream/<slug>.md`

```yaml
---
type: Event            # or Decision | Observation | Task | Outcome | UserNote
generated: { by: <actor>, at: <ISO 8601> }
importance: 1-10       # extension: Generative-Agents salience score
evidence: [episode slugs]   # extension: citations to prior episodes
tags: [...]
---
```

### What constitutes an event

An event is a **durable state change worth remembering in a future session**.
The filter is: *"will I need this next session?"* If no, it stays in chat and
does not become a file. Write an event when one of these occurs:

- **Decision** — a choice was made or reversed (by you or the agent).
- **Outcome** — a unit of work finished with a result worth remembering.
- **Observation** — a durable fact learned about the user or the world.
- **Task** — a bounded piece of work was undertaken (and its result).
- **UserNote** — the user stated a preference or fact about themselves.
- **Event** — catch-all for anything else consequential.

### Cadence

A **handful per productive exchange**, not per message and not per tool call.
Events fire at decision points, task completions, and durable-fact moments —
roughly 5–15 across a full working session, not hundreds. Log liberally but
score `importance` honestly so low-value events (1–2) don't drag reflection or
retrieval.

Append only. Never edit prior episodes. Use the actor convention (§7):
`<producer>/<version>` for the agent, `human:<id>` for you,
`process:<id>` for automation.

## Semantic (`semantic/`) — OKF concepts

Durable, de-contextualized. Three files: `user.md`, `decisions.md`,
`projects.md`. Each is an OKF concept (`type: Preference` / `Decision` /
`ProjectState`) carrying `generated: { by, at }` and `status`. Updated via
reflection only. Every entry dated via `generated.at` so newer supersedes
older — never accumulate two contradictory "active" facts.

## Reflection (consolidation)

Triggers:
(a) importance-sum of unreflected episodes ≥ ~150, or
(b) user invokes "consolidate memory".

Process:
1. Derive 3–5 salient questions from recent episodes.
2. Retrieve supporting evidence (scan episodic stream + semantic).
3. Synthesize ≤5 higher-level insights WITH citations:
   `insight — because episodes #a, #b`.
4. Append to `memory/episodic/reflections.md` (an OKF concept,
   `type: Reflection`) completing §4.1 conformance (`type` + `generated`).
5. Consolidate durable insights into `semantic/`, dedupe, supersede by
   `generated.at`.

## Governance (this is what makes files *memory*, not a dump)

- `raw/` is read-only (human-owned).
- `log.md` append-only; never rewrite history (OKF §9).
- `index.md` updated on every ingest/consolidation (OKF §8).
- Every episodic/semantic concept carries non-empty `type` (OKF §4.1).
- Semantic entries dated (`generated.at`) + superseded, never accumulated.
- `HOT.md` rewritten on session end, milestones, and pre-compaction; pruned
  below cap. A milestone (see above) also triggers a reflection-threshold check.