---
name: self-documenting-code
description: The user's code-style contract — code should be self-documenting: well-named, step-down ordered, short files, vertical whitespace between logical steps. Comments are a smell; intent lives in the project spec and acceptance criteria, never in source comments. Use when writing, reviewing, or refactoring code, when deciding whether a comment earns its place, or for any question of code style, formatting rhythm, blank lines, or error-message wording.
---

# self-documenting-code

The user's code-style contract: **code should be self-documenting**. If you
need comments to explain what the code does or why it is the way it is, the
code is not clear enough — or the intent belongs in the spec, not the
source.

## When to use

- Writing, reviewing, or refactoring code.
- Deciding whether a comment belongs.
- The user references self-documenting code, naming, comments, or code style.

## Core principles

1. **The code is the documentation.** A reader should understand what the code
   does from the code itself, not from comments around it.
2. **Intent lives in the spec, not the source.** Rationale, decisions, and
   non-obvious context belong in the project's spec and acceptance criteria.
   A comment carrying intent is misplaced documentation — move it to the
   spec.
3. **Comments are a smell.** If you're writing a comment to explain what a
   block does, the block is probably not clear enough. Rename, extract, or
   restructure instead.

## The rules

### Well-named functions and variables

A function's name states its intent; the body shows how. If a name needs a
comment to be understood, rename it.

Names matter more, not less, when agents read the code: identifiers are a
primary semantic channel for a model — it reasons from names, not only from
structure — so a descriptive name is compressed documentation the agent reads
directly.

- Name the behavior, not the mechanism: `calculateTotal()` not `loopAndSum()`.
- A boolean reads as a question: `isPublished()`, `hasExpired()`.
- Be specific: `maxRetries` not `count`.

### Step-down ordering

A file reads top-to-bottom like an outline: a function that calls another
appears above the one it calls. Public entry points first, then the helpers
they call, in decreasing abstraction.

### Vertical whitespace (breathing room)

Code needs horizontal formatting (Prettier) AND vertical rhythm (the
author's job — Prettier preserves at most one existing blank line and never
inserts one). Inside a method body:

- Separate logical steps with a blank line — the body reads like step-down
  prose: setup | act | outcome, each its own paragraph.
- Statements forming one step stay together; no blank line inside a step.
- A method that reads as one solid wall of statements is unfinished — add
  the blank lines, or the steps want extracting into named helpers.

Enforced by writing and review, not by auto-format.

### Short files

A file that needs section comments to navigate is too long. Split it (single
responsibility applied to files).

### Comments are nearly absent

Intent — decisions, rationale, non-obvious context — lives in the project's
spec and acceptance criteria, never in source comments. If a change needs
explaining, the spec gains a line and the code gains a better name. A
comment survives only in the rare case where nothing else can carry it at
the change site, and every survivor is a review flag.

## Documentation surfaces (where documentation lives, and when it updates)

Documentation has four surfaces. Each has a distinct job and an update
trigger — documentation that isn't tied to a trigger erodes:

1. **`ARCHITECTURE.md`** (repo root) — the codebase map: modules, boundaries,
   flows (mermaid sequence diagrams per path), the invariants, and the
   conventions. **Trigger: any flow or architecture change** — a new action, a
   reordered chain, a new decision point, a new invariant. A flow that ships
   without its diagram updated is unfinished; reviewers treat it as blocking.
2. **The behavioral contract** (feature specs in the vault,
   `planning/<slug>/specs/`) — what must be true, with stable criterion IDs and
   Given/When/Then scenarios, plus the intent and rationale behind the code.
   **Trigger: written at shaping time, before the code** (see `feature-spec`);
   amended only through an approved spec delta, never silently by the
   implementation.
3. **The vault** (`~/Documents/Obsidian/AI/`) — the documentation root for
   the project as a whole: the decision log (why it is the way it is), the
   session logs (what was done when), and the wiki (durable concepts that
   outlive the project). **Trigger: decisions log in the same session;
   durable insights    consolidate at session end.**
4. **Error messages** (in the code) — the diagnostic surface an agent reads at
   failure time. Carry the context a reader needs to act — the failing input,
   the constraint, the reason (`Payment failed for order #4521: insufficient
   funds`) — never a coded or terse string (`|E|PS|pf|o=4521`). A terse message
   forces the agent to reconstruct what the code could have said. This is the
   one place a descriptive string belongs in the source.

The boundary: the repo documents the code for someone **reading the code**;
the vault documents the project for someone **owning the project**. A flow
change updates both — `ARCHITECTURE.md` (how it works now) and the vault log
(that it changed, and why).

## The test

Before adding a comment, ask: **would a competent reader understand this
without it?** If yes, cut it. If no, the explanation belongs in the spec —
give the code a better name and put the intent where the project keeps its
contract.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-development` (the discipline), `code-review` (this
  contract is a review criterion).
- Wiki concept: `software-architecture-principles.md` (the "Self-documenting
  code" section this skill generalizes).
