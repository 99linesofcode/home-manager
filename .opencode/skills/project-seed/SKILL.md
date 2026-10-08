---
name: project-seed
description: Stand up a new project's foundation before any product work — the git repo and devshell (via new-project), the vault scratchpad (brief, decisions, open questions, specs), the repo's AGENTS.md standing rules, a stub ARCHITECTURE.md, and the gates. Use when starting a new project, "set up the foundation", or seeding a repo for spec-driven delivery.
---

# project-seed

Phase 1 of spec-driven delivery. No product work happens until this exists: the
repo, the scratchpad, the rules, the gates.

## When to use

- Starting a new project from scratch.
- "Set up the foundation", "seed the repo", before any feature work.

## Inputs

- What we're building, roughly (project type).
- The user's answers on stack/deployment — or "unknown yet", which becomes an
  open question.

## Steps

1. **Create the repo** — follow the `new-project` skill for the git repo,
   devshell, workflows, and labels. Never compose a scaffold from memory. Its
   Laravel steps apply only when the stack is Laravel; for any other stack, do
   the equivalent (repo + devshell + workflows + labels) and record the gates.
2. **Create the vault scratchpad** — `~/Documents/Obsidian/AI/planning/<slug>/`
   from `assets/scratchpad/`: `brief.md`, `decisions.md`, `open-questions.md`,
   and a `specs/` directory. The thinking lives here, not in the repo. The
   scratchpad is **transient** — consolidated into the wiki/memory and trashed
   when the effort completes (see `slice-delivery` close-out).
3. **Write the repo's `AGENTS.md`** from `assets/AGENTS.template.md` — project
   summary placeholder, build/test/lint commands, the seven standing rules. This
   is the context file every session reads first.
4. **Stub `ARCHITECTURE.md`** from `assets/ARCHITECTURE.template.md`. It fills
   in at Phase 4; the stub claims the location.
5. **Define the gates** — choose typecheck / lint / format:check / tests /
   build / boundary gate for this stack and record the commands in `AGENTS.md`.
   Phase 4's walking skeleton wires them into CI.
6. **Materialize the project** — create the OPM project in the vault (the
   anchor; see `vault-notes` for where project notes live), with its GitHub
   connection pointing at the new repo, so work has somewhere to land.
   Milestones are a manual step until OPM supports them.

## Delegating

- Nothing here is a role's work — seeding is orchestrator work. Dispatch
  `new-project`'s scaffold steps if they are heavy.

## Outputs

- The repo + devshell + workflows.
- `planning/<slug>/` (scratchpad).
- `<repo>/AGENTS.md`, `<repo>/ARCHITECTURE.md` (stub).
- Gate commands recorded in `AGENTS.md`.

## Exit criteria

- The repo pushes, the devshell loads, the gates run (even trivially).
- `AGENTS.md` carries the seven standing rules.
- The scratchpad exists and the OPM project points at the repo.

## Must not

- Write product/application code.
- Choose the architecture (that is Phase 4).
- Invent requirements — unknowns go to `open-questions.md`.

## Related

- **Loads:** `new-project` (scaffolding).
- **References:** `git-workflow`, `software-development`, `vault-notes`,
  `software-architecture` (ARCHITECTURE.md), `agent-delegation`.
