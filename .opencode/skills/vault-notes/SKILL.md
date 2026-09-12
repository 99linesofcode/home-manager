---
name: vault-notes
description: Create and maintain notes in the user's Obsidian vault following the categories-only + affiliation model (Steph Ango's system married to PARA). Categories = kinds (Books, Recipes, Poems, Bookmarks, Notes, Contacts, Organizations, Projects, Meetings, Documents, Quotes) driving bases; affiliation groups notes by organization/person; entity notes and project homes are the MOCs. Use when the user asks to create a note, person, organization, project, meeting, or to reorganize/clean the vault.
---

# vault-notes

Create and maintain notes in the user's Obsidian vault. The vault runs on a
**categories-only + affiliation** model (Steph Ango's note system married to
PARA). This skill is the source of truth for the vault's structure; the wiki
concept page `wiki/concepts/para-note-organization.md` may lag behind it.

Vault root: `~/Documents/Obsidian/`. The vault is **Dutch**: folder names,
filenames, and note content are Dutch. Property names are **English**; the
`AI/` folder is fully English.

## The model in one line

**Categories are the kind of thing a note is** (Books, Recipes, Poems,
Bookmarks, Notes, Contacts, Organizations, Projects, Meetings, Documents,
Quotes). Each category links to a base file and drives a live base view.
**Tags are lightweight markers** (topics/state) — never used to organize.
**Affiliation groups notes by organization or person.** There is no `type`
property and no `title` property.

## Vault layout

Top-level folders:

- `Inbox` — capture, raw dump (immutable source material)
- `Projecten` — active projects, one folder per project
- `Verantwoordelijkheden` — responsibilities: `Opdrachtgevers/` (organizations),
  `Personen/` (contacts)
- `Referenties` — reference material, organized by category folder
- `Archief` — inactive items (flat, unorganized — park and forget)
- `Bases` — the `.base` files (database views)
- `Templates` — note templates
- `TaskNotes` — task/agenda views
- `AI` — the agent's wiki + memory (fully English)

**Inbox is a raw dump area.** Contents may lack frontmatter/tags/structure —
that's expected. Treat Inbox contents as immutable source material: process +
discard original, never edit in place. Processing = ingest (e.g. into the
wiki) then **discard the original** — never move it to `Archief/`.

## Categories (kinds) → base → template

Each category is a kind of note. The `categories` frontmatter property holds a
link to the base file with a display alias:

```yaml
categories:
  - "[[Books.base|Books]]"
```

| Category | Base | Template | Where it lives |
|---|---|---|---|
| Books | `Books.base` | `Book.md` | `Referenties/Boeken/` |
| Recipes | `Recipes.base` | `Recipe.md` | `Referenties/Recepten/` |
| Poems | `Poems.base` | `Poem.md` | `Referenties/Gedichten/` |
| Bookmarks | `Bookmarks.base` | `Bookmark.md` | `Referenties/Bladwijzers/` |
| Notes | `Notes.base` | (tags: idea/journal/plan/reference) | `Referenties/Notities/` + project notes |
| Contacts | `Contacts.base` | `Contact.md` | `Verantwoordelijkheden/Personen/` |
| Organizations | `Organizations.base` | `Organization.md` | `Verantwoordelijkheden/Opdrachtgevers/` |
| Projects | `Projects.base` | `Project.md` | `Projecten/<project>/` |
| Meetings | `Meetings.base` | `Meeting.md` | inside a project folder |
| Documents | `Documents.base` | `Contract.md` / `Maintenance Contract.md` | `Referenties/` or `Archief/` |
| Quotes | `Quotes.base` | `Quote.md` | `Archief/` |

**Referenties is organized by category folder** — never by topic or tag. The
folders are `Boeken/`, `Recepten/`, `Gedichten/`, `Bladwijzers/`, `Notities/`.
Nothing deeper than one level.

## Properties (English names, Dutch values)

Core schema, shared across categories. Each property has a **role** — a
responsibility in the system. The two structural properties (`categories`,
`affiliation`) drive the bases; the rest are descriptive metadata.

| Property | Type | Role | What it does |
|---|---|---|---|
| `categories` | list | **Classification** | The kind of file. A link to the base file with display alias (`"[[Books.base\|Books]]"`). Determines which base the note appears in and where it lives. One per note. |
| `affiliation` | list | **Relationship** | Connects a file to an entity (org, person, project, meeting — anything a relationship makes sense for). Quoted wikilinks (`- "[[Bloei Interieurbeplanting]]"`). Drives the `byAffiliation` base views that aggregate an entity's associated files in its MOC. |
| `tags` | list | **Markers** | Lightweight topics/state for search and filtering (e.g. `software-development`, `to-read`). Never used to organize or drive bases. |
| `created` | date | **Provenance** | When the note was added (`YYYY-MM-DD`). Used for sorting and temporal context. |
| `url` | text | **Destination** | The external link a bookmark points to. A bookmark's actual content — bookmarks have no body. |
| `source` | text | **Origin** | Where a book comes from (store/page URL). A book's actual content — books have no body. |
| `author` / `year` | text / number | **Attribution** | Who made the work and when (Books, Poems). |
| `status` | list | **State** | Progress tracking, e.g. `to-read`, `reading`, `read`. |
| `genre` / `isbn` | list / text | **Identity** | Book classification and identification. |
| `birthday` / `email` / `phone` | date / text | **Contact** | How to reach a person (Contacts). |
| `street` / `house number` / `postalcode` / `city` / `vat` / `coc` | text | **Identity** | Legal/business identity of an organization. |
| `location` / `date` | text / date | **Logistics** | When and where a meeting happened. |
| `subtitle` / `lang` | text | **Identity** | Document metadata (Quotes, Contracts). |

Rules:
- **No `type` property.** The kind lives in `categories`.
- **No `title` property on regular notes.** Obsidian's `note.title` is a
  built-in file property that falls back to the filename — bases display it
  automatically. Exception: formal documents (Quotes, Contracts) keep a
  `title` because they're named documents.
- **Affiliation values must be quoted** (`- "[[Org]]"`). Unquoted
  (`- [[Org]]`) parses as a nested YAML flow sequence and breaks the link.
- **Bookmarks have no body** — the URL lives in the `url` property only.
- **Books have no body** — the external link lives in the `source` property
  only.
- **Short, reusable names** (Steph): `created` not `date-created`; `author`
  works across books, poems, media.

## Affiliation model

`affiliation` is the **relationship layer** of the vault. It establishes a
connection between a file and an entity — an organization, a person, a
project, a meeting, anything where such a relationship makes sense. It is not
limited to clients; it is a general "this belongs to / is associated with
that" link.

A file carries the entities it relates to:

```yaml
affiliation:
  - "[[Bloei Interieurbeplanting]]"
  - "[[kerstboom-verhuur.nl]]"
```

A note can be affiliated to more than one entity. The values are quoted
wikilinks so they resolve as links.

**What affiliation drives:** the `byAffiliation` base views. Every entity note
(Organization, Person) and project home file is a **MOC** (Map of Content) —
its home. It embeds the bases filtered by affiliation, so it displays every
file associated with that entity. The base's `byAffiliation` view filters
`list(affiliation).contains(this)`, where `this` is the embedding MOC — a
live, auto-updating map of everything connected to that entity. This replaces
the old hand-maintained `_home.md` MOCs.

## Bases

Bases turn a category into a live table/list. Data stays in the notes'
frontmatter; the `.base` file only describes the view. All bases live in the
top-level `Bases/` folder.

**Filter pattern (category-scoped):**

```yaml
filters:
  and:
    - file.ext == "md"
    - list(categories).contains(link("Books.base"))
    - '!file.inFolder("Templates")'
```

**Per-affiliation view** (embedded in an entity/project note to show only that
context's files):

```yaml
views:
  - type: table
    name: byAffiliation
    filters:
      and:
        - list(affiliation).contains(this)
```

`this` is the embedding note. When the base is embedded in an entity note, it
shows only files whose `affiliation` includes that entity.

**Clickable rows:** add a link formula and display it as the first column:

```yaml
formulas:
  link: file.asLink(note.title)
properties:
  formula.link:
    displayName: Naam
```

**Embedding:** `![[Name.base]]` shows the first view; `![[Name.base#View]]`
shows a specific view. Embed by name, never by path, so re-nesting never
breaks embeds. Base names must be unique in the vault.

## MOC files (the "home")

**MOC = Map of Content.** A MOC is a note that serves as the index/overview
for a set of related notes. In this vault, the MOCs are the **entity notes**
(Organization, Person) and the **project home files**. Each is the "home" for
its entity: it aggregates everything associated with that entity via embedded
base views.

A MOC contains exactly two things:

1. **Frontmatter** — the entity/project metadata (contact info, affiliation,
   category, created).
2. **Embedded base views** — sections that aggregate related notes via
   `![Notes](Notes.base#byAffiliation)`, `![Projects](Projects.base#byAffiliation)`,
   `![Meetings](Meetings.base#byAffiliation)`, `![Quotes](Quotes.base#byAffiliation)`.

**No prose.** The MOC is a pure aggregation point — the content lives in the
individual notes. Keep MOCs minimal: frontmatter + embedded base views. The
bases do the work; the MOC just points at them.

**Entity note (Organization):**

```markdown
---
street: Turnhoutlaan
house number: 23
postalcode: 5628 RJ
city: Eindhoven
email: info@bloei-interieurbeplanting.nl
categories:
  - "[[Organizations.base|Organizations]]"
tags: []
---

## Contacten
![[Contacts.base#byAffiliation]]

## Offertes
![Quotes](Quotes.base#byAffiliation)

## Projecten
![Projects](Projects.base#byAffiliation)

## Notities
![Notes](Notes.base#byAffiliation)
```

**Project home file** (one per project folder, named after the project):

```markdown
---
affiliation:
  - "[[Bloei Interieurbeplanting]]"
created: 2026-09-12
categories:
  - "[[Projects.base|Projects]]"
tags: []
---

## Offertes
![Quotes](Quotes.base#byAffiliation)

## Notities
![Notes](Notes.base#byAffiliation)

## Meetings
![Meetings](Meetings.base#byAffiliation)
```

## Creating a note — procedure

1. Determine the category (kind) and the folder it belongs in.
2. Pick the path per the naming conventions.
3. Write the file using the matching template in `Templates/` (or the pattern
   below), filling the frontmatter.
4. Set `affiliation` where the note belongs to an org/person.
5. Link it from related notes with `[[wikilinks]]`.

## File templates (frontmatter patterns)

**Book** (`Referenties/Boeken/`):
```yaml
author:
year:
genre: []
isbn:
source: <url>
status: []
created: YYYY-MM-DD
categories:
  - "[[Books.base|Books]]"
tags:
```

**Recipe** (`Referenties/Recepten/`):
```yaml
created: YYYY-MM-DD
categories:
  - "[[Recipes.base|Recipes]]"
tags:
```

**Poem** (`Referenties/Gedichten/`):
```yaml
author:
year:
created: YYYY-MM-DD
categories:
  - "[[Poems.base|Poems]]"
tags:
```

**Bookmark** (`Referenties/Bladwijzers/`) — no body:
```yaml
url: <url>
created: YYYY-MM-DD
categories:
  - "[[Bookmarks.base|Bookmarks]]"
tags:
```

**Note** (`Referenties/Notities/` or a project note) — tag marks the kind:
```yaml
affiliation: []
created: YYYY-MM-DD
categories:
  - "[[Notes.base|Notes]]"
tags:
  - reference   # or idea / journal / plan
```

**Contact** (`Verantwoordelijkheden/Personen/`):
```yaml
affiliation: []
birthday:
email:
phone:
created: YYYY-MM-DD
categories:
  - "[[Contacts.base|Contacts]]"
tags:
```

**Organization** (`Verantwoordelijkheden/Opdrachtgevers/`):
```yaml
street:
house number:
postalcode:
city:
email:
phone:
vat:
coc:
created: YYYY-MM-DD
categories:
  - "[[Organizations.base|Organizations]]"
tags:
```

**Project** (`Projecten/<project>/`):
```yaml
affiliation:
  - "[[Org]]"
created: YYYY-MM-DD
categories:
  - "[[Projects.base|Projects]]"
tags: []
```

**Meeting** (inside a project folder):
```yaml
affiliation:
  - "[[Org]]"
location: Remote
date: YYYY-MM-DD
categories:
  - "[[Meetings.base|Meetings]]"
tags:
```

**Quote** (`Archief/`):
```yaml
title:
subtitle:
lang: nl
affiliation:
  - "[[Org]]"
categories:
  - "[[Quotes.base|Quotes]]"
tags:
  - document
  - quote
```

## Naming conventions

- Chronological streams: date-prefix `YYYY-MM-DD - title.md`.
- Project folders: kebab-case slug, e.g. `Projecten/kerstboom-verhuur.nl/`.
- Project home file: named after the project (e.g. `kerstboom-verhuur.nl.md`),
  not `_home.md`.
- Meetings: date-prefix `YYYY-MM-DD <onderwerp>.md`.
- Bookmarks: the resource's title (resolve actual titles for generic names
  like "YouTube").

## Edge cases

- **Ambiguous category** — if unsure whether a note is a Project or a Note,
  ask the user rather than guessing.
- **Never too deep** — Referenties is one level of category folders; don't
  nest deeper.
- **Inbox item** — process (ingest) then **discard the original**; never move
  it to `Archief/`.
- **Archief is flat** — a single unorganized bucket, not a category structure.
  Move whole project folders in as-is; don't create subfolders. Archived items
  keep their categories (so they stay findable via bases/search). Retrieval is
  by search or base, not by browsing the tree.

## Maintenance procedures

- **Update living sections:** when the user mentions an org/person/project
  update, update the relevant entity/project note's frontmatter.
- **Archive a project:** when a project finishes, move its folder to
  `Archief/` as-is (flat — no subfolder).
- **Sweep:** on request, scan for stale links, missing affiliations, and files
  that should be promoted or archived.
