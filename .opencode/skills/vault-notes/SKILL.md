---
name: vault-notes
description: Create and maintain PARA-structured notes in the user's Obsidian vault — person files, process files, project directories, journal entries, area home files, resource MOCs. Use when the user asks to create a new person, process, project, journal entry, or note folder, or to sweep an area for stale links and open loops.
---

# vault-notes

Create and maintain notes in the user's Obsidian vault following the PARA +
Journal conventions defined in `wiki/concepts/para-note-organization.md`
(under `~/Documents/Obsidian/AI/`). Read that page first if you haven't seen
it this session.

## The vault layout

Seven top-level buckets (display order maintained by an Obsidian plugin, no
numbering):

- `Inbox` — capture, unprocessed
- `Projecten` — active work with a finish line
- `Werk` — work projects/areas (user-specific)
- `Aandachtsgebieden` — ongoing responsibilities, no end date
- `Hulpbronnen` — topics and reference material
- `Archief` — everything inactive
- `Dagboek` — diary / time-stream

Vault root: `~/Documents/Obsidian/`.

The vault is **Dutch**: folder names are Dutch and must stay Dutch. See
`wiki/concepts/para-note-organization.md` for the English→Dutch mapping.

**Inbox is a raw dump area.** Anything the user pastes there may lack
frontmatter, tags, or structure — it is not OKF-compliant and is not expected
to be. Treat Inbox contents as immutable source material: read and move out,
never edit in place. **Processing an Inbox item means ingesting it (e.g. into
the wiki) and then discarding the original — never move it to `Archief/`.**
Archief is for inactive PARA items, not for processed source material.

## Decision tests (when placing a note)

- **Project or Area?** Does it have an end date? Yes → Projecten. No →
  Aandachtsgebieden.
- **Area or Resource?** Is it a responsibility the user maintains, or a topic
  of interest? Me → Aandachtsgebieden. Topic → Hulpbronnen.

## Depth rules

- Level 1: the seven buckets.
- Level 2: domains (project slugs, area names, topics).
- Level 3: ONLY high-volume recurring types (`meetings/`, `people/`,
  `research/`).
- Never level 4. If you hit 4, flatten.
- A folder earns its place at **3+ files of a recurring type** — never for a
  topic. Topics get a `_home.md` MOC note that links to the files.

## Naming conventions

- Chronological streams: date-prefix files `YYYY-MM-DD - title.md`.
- Recurring kinds in a flat area: type-prefix `person - name.md`,
  `process - name.md`.
- Project folders: kebab-case slug, e.g. `Projecten/website-redesign/`.
- Dagboek entries: `Dagboek/YYYY/YYYY-MM-DD.md`.

## File templates

### `person - name.md` (entity note — a hub others link to)

```markdown
---
type: person
tags: [work, people]
---

# Alice

- **Role:** Product designer, billing team
- **Contact:** alice@company.com · @alice on Slack
- **Reports to:** Bob

## Context
Met at the billing redesign kickoff (2026-08-14). She owns the UX side of the
payment flow.

## Key facts
- Prefers async feedback over meetings
- Birthday: March 12

## Open loops
- [ ] Send her the competitor-analysis research notes (2026-09-10)

## History
- 2026-09-03 — weekly standup: she flagged the payment error states
- 2026-08-14 — kickoff meeting
```

Stable facts up top; living sections (Open loops, History) fill in as the
user interacts. Every note that mentions the person links `[[person - name]]`.

### `process - name.md` (runbook — consult when doing the thing)

```markdown
---
type: process
tags: [work, finance]
---

# Expense report

File a monthly expense report via the finance portal.

## Steps
1. Collect receipts (scan or photo) into `~/Documents/expenses/2026-09/`
2. Log into finance portal → Expenses → New report
3. Add each receipt: date, amount, category, project code
4. Attach receipts as PDFs
5. Submit → approval goes to Finance team
6. Reimbursement lands in ~5 business days

## Gotchas
- Receipts under €25 don't need a PDF, just the line item
- Travel expenses need the project code or they bounce back
- Deadline: last Friday of the month

## Links
- [[finance portal guide]]
- [[person - finance-contact]]
```

One-line purpose, numbered steps, gotchas, links. Written once when the user
figures the thing out; gotchas appended when hit.

### `_home.md` (project / area / resource MOC — the folder's index)

```markdown
---
type: moc
tags: [project, website-redesign]
---

# Website redesign

- **Goal:** relaunch marketing site on the new stack
- **Status:** in progress — copy draft v2 under review
- **Deadline:** 2026-11-01

## Links
- [[2026-09-03 - kickoff]]
- [[research-competitors]]
- [[person - alice]]
```

The only file that is always present in a project/area/resource folder. Goal,
status, and links to everything else. It is the folder's `index.md`.

### Dagboek entry

```markdown
---
type: journal
---

# 2026-09-03

(Free-form entry. No structure required — it's a time-stream.)
```

## Linking rules

- Always link people, processes, and projects from new notes with
  `[[wikilinks]]`.
- Backlinks are automatic in Obsidian — never manually maintain them.
- After creating a note, check Obsidian's **Unlinked Mentions** for missed
  links and offer to fix them.

## Maintenance procedures

- **Update living sections:** when the user mentions a person/process/project
  update, append to History / update Open loops / status in the relevant file.
- **Promote prefix → folder:** when a flat area has 3+ files of the same
  recurring type, offer to promote them to a folder (content unchanged).
- **Archive a project:** when a project finishes, move its folder to Archief.
- **Sweep:** on request, scan an area for stale open loops, missing links, and
  files that should be promoted or archived.