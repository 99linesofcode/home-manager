---
name: research-prompt-skills
description: Self-adjusting research sweep on prompt engineering, agent memory, context optimization, and skill authoring. Built for scheduled standalone opencode sessions (systemd timer): grounds in the skill-research wiki pages, dedups against prior sweeps, applies a strict evidence bar, writes a dated findings note to the vault Inbox, and stretches or tightens its own schedule based on verified-finding volume. Use when running the research-prompt-skills scheduled job or when asked to do a prompt/skill research sweep.
license: MIT
compatibility: opencode
---

# Research sweep: prompting, memory, context & skill architecture

You are running headless on a schedule in a standalone session. Work
autonomously; do not ask questions.

## Procedure

1. Ground yourself in what we already know. Read these wiki pages (paths
   relative to the working directory):
   - wiki/concepts/agent-skill-retrieval-research.md
   - wiki/concepts/llm-context-conditioning.md
   - wiki/syntheses/skill-architecture.md
2. Cross-run dedup: list ~/Documents/Obsidian/Inbox/*prompt-skill-research*.md.
   Read the most recent one. Skip anything it already covers, and note its
   `verified-findings:` count — you need it for the trend check in step 5.
3. Search the web for developments since the last sweep (or roughly the
   last month, if no prior note exists) in:
   - persistent memory for agents: memory architectures, consolidation,
     retrieval, forgetting, what persists across sessions, benchmarks
   - context optimization: selection, ordering, compression, what to drop,
     context engineering practice
   - skill authoring and wording: how phrasing affects skill activation and
     adherence, Agent Skills spec and ecosystem changes
   - broad agent insights: prompting techniques, agent architecture,
     autonomy and scheduling patterns — anything else notable
4. Evidence bar. Hundreds of AI papers appear daily; most never replicate.
   A finding is something you would act on:
   - confirmed by a meta-analysis, an independent replication, or strong
     ablations from an established lab, OR
   - a practice already validated in production by multiple credible teams.
   Single unreplicated preprints are watchlist items: list them separately,
   clearly marked, and name the evidence that would promote them. Never
   recommend adopting a watchlist item.
5. Write your findings to
   ~/Documents/Obsidian/Inbox/<today as YYYY-MM-DD>-prompt-skill-research.md:
   - A `verified-findings: N` line (N = items that passed the evidence bar).
     This is the trend signal — always present, `0` if nothing passed.
   - What is new since the last sweep (or since the wiki pages were written,
     if no prior sweep exists)
   - What contradicts or extends the wiki pages above
   - Adoption recommendations, one line each, each tagged with its evidence
     level (meta-analysis / replicated / production-validated)
   - Watchlist: unreplicated but interesting, with the missing evidence named
   - Cite every claim with a URL. Dense, no filler.
6. Do not edit anything under wiki/. Inbox only. You may append one episodic
   event to memory/episodic/stream/ recording the run outcome, but never
   rewrite memory/HOT.md — the live session owns it.

## Schedule self-adjustment

Compare this sweep's `verified-findings` count with the previous sweep's.
No prior note means no trend data: keep the current schedule.

- Ladder: monthly → quarterly → semiannually. One step maximum per sweep.
- Stretch one step when the count fell versus the previous sweep AND is ≤ 2
  (low volume, falling).
- Otherwise keep the current schedule.

When the schedule changes:

1. Edit this job's `schedule` value in
   ~/Development/home-manager/modules/opencode.nix (inside the
   `scheduledJobs` default). Keep Nix syntax valid. Use the OnCalendar
   expression for the new cadence:
   - monthly: `*-*-01 12:00`
   - quarterly: `*-01,04,07,10-01 12:00:00`
   - semiannually: `*-01,07-01 12:00:00`
2. Do NOT commit and do NOT run home-manager switch — the user does that.
3. Notify the user:
   `notify-send -u normal "research sweep" "Schedule changed to <cadence> (<N> verified findings). Run home-manager switch to apply."`
   and record the change (old → new, with the counts) in the note.
