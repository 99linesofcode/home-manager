---
name: wiki
description: The LLM-wiki maintenance procedure (Karpathy). Ingest sources from the vault Inbox, write and cross-link wiki pages, maintain index.md and log.md, answer with citations, and lint for health. Loaded on demand by the orchestrator.
license: MIT
---

# Wiki (LLM-wiki procedure)

You maintain the vault's agent-owned knowledge layer (`wiki/`) over sources
captured in the vault `Inbox/` (the PARA capture point, a top-level folder in
the vault at `~/Documents/Obsidian/Inbox/`), per the contract in `AGENTS.md`. This skill is
the *how-to*; `AGENTS.md` is the *contract*.

## When loaded

The orchestrator loads you when a task is a wiki operation: ingest, query-
against-wiki, or lint. Do not assume you're loaded otherwise.

## Operation 1 — Ingest (source → wiki)

When the user drops a source into the vault `Inbox/` and says "ingest" (or
equivalent):

1. Read the source file in `Inbox/`. **Treat it as immutable source material:
   never edit, reformat, or "fix" anything in `Inbox/`.** Contents may lack
   frontmatter, tags, or structure — that's expected, it's a raw dump area.
2. Discuss 3–5 key takeaways with the user (confirm emphasis).
3. Write `wiki/sources/<slug>.md` — full summary; YAML frontmatter with
   `type: Source` (or a specific source type) + `generated: { by, at }` +
   `source_file` pointing at the `Inbox/` path (OKF `sources`/provenance).
4. Update `wiki/index.md` — add the page with a one-line summary.
5. Update every relevant `entities/` and `concepts/` page with new facts,
   cross-referencing the source.
6. If new info **contradicts** an existing page, flag it with a
   `[!contradiction]` callout — never silently overwrite.
7. Append a structured entry to `wiki/log.md` (see Log format below).
8. **Discard the original Inbox file** — it has been processed. Never move it
   to `Archief/`; Archief is for inactive PARA items, not processed sources.

## Operation 2 — Query (answer against the wiki)

When asked a question the wiki may answer:

1. Read `wiki/index.md` first to locate candidates.
2. Drill into the relevant pages (and their back-links).
3. Synthesize an answer with **citations** to the pages/sources used.
4. If the answer is a new comparison/analysis worth keeping, file it as a
   `comparisons/` or `syntheses/` page (back-linked), and update `index.md`.

## Operation 3 — Lint (health-check)

When asked to "lint" (or periodically):

1. Find contradictions between pages.
2. Find stale claims superseded by newer sources.
3. Find orphan pages (no inbound links).
4. Find important concepts mentioned but lacking a page.
5. Find missing cross-references and data gaps (suggest web searches).
6. Report findings as a list; apply fixes only for the unambiguous ones, and
   propose the rest to the user.

## Example — an ingest

User drops `Inbox/agentskills-spec.md` and says "ingest this":

1. Read the file in `Inbox/` (do not edit it).
2. Confirm 3–5 takeaways with the user.
3. Write `wiki/sources/agentskills-spec.md` (`type: Source`, `source_file:
   "Inbox/agentskills-spec.md"`, `generated: { by, at }`).
4. Add a one-line entry to `wiki/index.md` under Sources.
5. Update any `entities/`/`concepts/` pages the source touches.
6. Append `## [2026-09-04] ingest | agentskills spec` to `wiki/log.md`.
7. Discard `Inbox/agentskills-spec.md`.

## Edge cases

- **Contradiction** — new source conflicts with an existing page. Flag with a
  `[!contradiction]` callout; never silently overwrite.
- **Source is huge** — summarize the key claims, don't paste the whole thing;
  keep the `sources/` page focused and link out.
- **No matching entity/concept page** — create one, or note it as a gap rather
  than forcing the fact into an unrelated page.
- **Inbox file already gone** — if the source was already processed, don't
  re-ingest; check `wiki/log.md` for the prior entry.
- **Orphan page** — a page with no inbound links after ingest; add back-links
  or flag it in a lint pass.

## Log format

Append-only, newest entries under `## YYYY-MM-DD`. Each line starts with a
machine-parseable prefix for `grep "^## \["` style tooling:

```
## [2026-08-31] ingest | Title of source
* Wrote wiki/sources/<slug>.md; updated entities/a.md, concepts/b.md
```

## Governance (inherited from AGENTS.md)

- `Inbox/` is the capture point; contents are raw dumps (not OKF-compliant),
  treated as immutable source material — process + discard original, never
  edit in place. Processing = ingest + **discard the original** (never archive it).
- `index.md` on every ingest; `log.md` append-only.
- Contradictions flagged, never silently resolved.
- Every page carries non-empty `type` + `generated` (OKF v0.2).