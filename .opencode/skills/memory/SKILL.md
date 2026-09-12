---
name: memory
description: Two-tier file-native memory system (working + episodic/semantic with milestone-triggered reflection and codification pruning), grounded in Generative Agents and Files-as-Memory research. Emits OKF v0.2-conformant concepts.
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
changed. It triggers a `HOT.md` rewrite **and** a reflection pass. A milestone
is any of, whichever comes first:

1. A unit of work reaches "done" (a triage class-2/3 task completes).
2. An open loop is closed or a decision is recorded.
3. A Wayfinder phase transition occurs (interview → map → resolve → spec → promote).
4. Fallback: 5+ episodic events written since the last milestone, or ~30 min of
   active work.

"Session end" and "before compaction" are additional rewrite triggers, but they
are not reliably signaled by the harness — treat the explicit milestone criteria
above as the dependable cadence, and the "consolidate memory" command as the
deterministic reflection trigger. **Reflection runs at every milestone**, not
only when a threshold is crossed — see Reflection below.

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

**Keep events lean.** One file per event, body capped at a title + 2–4 lines.
If a write-up needs more than that, it belongs in the wiki or a skill, not in
the episodic stream. **Use only the six types above** — `Decision`, `Outcome`,
`Observation`, `Task`, `UserNote`, `Event`. Anything else (e.g. `Episode`,
`User Note`, `Episodic Event`) is a typo; normalize to the canonical set.

Append only. Never edit prior episodes. Use the actor convention (§7):
`<producer>/<version>` for the agent, `human:<id>` for you,
`process:<id>` for automation.

### Example — a full event file

```markdown
---
type: Decision
generated: { by: orchestrator/1, at: 2026-09-04T19:30:00+02:00 }
importance: 7
evidence: [2026-09-04-typst-skill-zakelijk]
tags: [skills, typst]
---
# Decided: typst-document skill command

The command is `cd ~/Development/99linesofcode-typst-template && pandoc ...`.
Output defaults to `~/Documents/`.
```

### Example — a HOT.md rewrite (milestone)

After a unit of work reaches done, rewrite `HOT.md` with the new focus, the
closed loop moved out of Open loops, the decision recorded under Last
decisions, and the next action updated. Keep it under 2000 tokens.

## Edge cases

- **Importance inflation** — scoring every event 8–10 drags reflection and
  retrieval. Reserve high scores for genuinely consequential state changes;
  most events are 3–6.
- **Over-logging** — writing an event per message or tool call floods the
  stream. The filter is "will I need this next session?"; if not, it stays in
  chat.
- **Contradictory semantic facts** — never let two "active" facts coexist.
  Newer `generated.at` supersedes older; add a `supersedes` link when one
  replaces another.
- **HOT.md over budget** — discard richest detail first, keep `Handoff` and
  `Next action` last.
- **Reflection backlog** — reflection runs at every milestone (see below), so
  the unreflected backlog stays small. If it ever grows large (importance-sum
  near ~150), run reflection immediately rather than writing more episodes.

## Semantic (`semantic/`) — OKF concepts

Durable, de-contextualized. Three files: `user.md`, `decisions.md`,
`projects.md`. Each is an OKF concept (`type: Preference` / `Decision` /
`ProjectState`) carrying `generated: { by, at }` and `status`. Updated via
reflection only. Every entry dated via `generated.at` so newer supersedes
older — never accumulate two contradictory "active" facts.

**`decisions.md` is a list of single, timestamped sentences** — one decision
per line, dated, no prose blocks. If a decision needs more than a sentence to
explain, the explanation belongs in a skill, AGENTS.md, or a wiki concept, not
in decisions.md.

**Codification rule (prune on codify).** decisions.md holds only standing
decisions *not* codified elsewhere. When a decision is codified into a skill,
AGENTS.md, or config (e.g. `opencode.nix`, `obsidian.nix`), remove it from
decisions.md — or leave a one-line pointer if the "why" is worth keeping. The
codified artifact is the source of truth; memory does not duplicate it. Run
this prune as part of every reflection pass.

## Reflection (consolidation)

Triggers — **runs at every milestone** (see Milestones) and on session end,
plus:
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
6. **Prune codified decisions** — remove from `decisions.md` anything now
   codified in a skill, AGENTS.md, or config (see Codification rule).

## Governance (this is what makes files *memory*, not a dump)

- `Inbox/` is the capture point; contents are immutable source material —
  process + discard original, never edit in place.
- `log.md` append-only; never rewrite history (OKF §9).
- `index.md` updated on every ingest/consolidation (OKF §8).
- Every episodic/semantic concept carries non-empty `type` (OKF §4.1).
- Semantic entries dated (`generated.at`) + superseded, never accumulated.
- **Codification rule** — decisions codified into a skill, AGENTS.md, or config
  are pruned from `decisions.md` (or reduced to a one-line pointer). Memory
  does not duplicate codified artifacts.
- `HOT.md` rewritten on session end, milestones, and pre-compaction; pruned
  below cap. A milestone (see above) also triggers a reflection pass.