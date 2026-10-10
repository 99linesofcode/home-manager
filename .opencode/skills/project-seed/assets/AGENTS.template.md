# <Project> — working rules

<One paragraph: what this is.>

## Build / test / lint

- Install: `<cmd>`
- Test: `<cmd>`
- Typecheck: `<cmd>`
- Lint: `<cmd>`
- Format check: `<cmd>`
- Boundary check: `<cmd>`

## Where things live

- `ARCHITECTURE.md` — the map: modules, boundaries, flows (mermaid), conventions.
- `docs/architecture/` — ADRs.
- `features/` — executable scenarios, tagged by criterion ID.
- The brief, decisions, open questions, and specs live in the vault at
  `~/Documents/Obsidian/AI/planning/<slug>/`.

## Standing rules

1. Never modify, weaken, skip, or delete a test to make it pass; if a test seems
   wrong, stop and report.
2. Tests change only through an approved spec delta — never to reach green.
3. Never invent product behavior; ambiguity goes to the open-questions register
   and to me.
4. Every behavior change updates its spec.
5. Work in small slices; each ends green and committed.
6. State lives in files, not chat — start each session by reading the named
   files.
7. Roles are separate: the implementer never writes tests; the test author never
   sees the implementation.

## Governing skills

Referenced by name, not restated: `software-development`,
`software-architecture`, `software-testing`, `self-documenting-code`,
`code-review`, `git-workflow`.
