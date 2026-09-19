---
name: self-documenting-code
description: The user's code-style contract — code should be self-documenting: well-named, step-down ordered, short files, vertical whitespace between logical steps, and comments that explain WHY not WHAT. Comments are a smell; fix the code, not the comment. Use when writing, reviewing, or refactoring code, when deciding whether a comment earns its place, or for any question of code style, formatting rhythm, or blank lines.
---

# self-documenting-code

The user's code-style contract: **code should be self-documenting**. If you
need extensive comments to explain what the code does, the code is not clear
enough — fix the code, not the comment.

This is not "no comments." It's a standard for when comments earn their keep.

## When to use

- Writing, reviewing, or refactoring code.
- Deciding whether a comment belongs.
- The user references self-documenting code, naming, comments, or code style.

## Core principles

1. **The code is the documentation.** A reader should understand what the code
   does from the code itself, not from comments around it.
2. **Comments explain WHY, never WHAT.** A comment that restates the code is
   noise. A comment that records a non-obvious decision, a protocol quirk, or a
   warning is valuable and stays.
3. **Comments are a smell.** If you're writing a comment to explain what a
   block does, the block is probably not clear enough. Rename, extract, or
   restructure instead.

## The rules

### Well-named functions and variables

A function's name states its intent; the body shows how. If a name needs a
comment to be understood, rename it.

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

### Comments that earn their keep

Keep comments that record:

- **Non-obvious decisions** — "we retry here because the upstream API is
  eventually consistent."
- **Protocol quirks** — "this endpoint returns 204 on success, not 200."
- **Warnings** — "never log here — this runs inside the TUI."

Cut comments that restate the code:

```text
// BAD: increments the counter
$counter++;

// GOOD: why we increment here
// The upstream webhook can fire twice; this dedupes.
$counter++;
```

## The test

Before adding a comment, ask: **would a competent reader understand this
without it?** If yes, cut it. If no, first try to make the code clearer; only
if the clarity can't come from the code (a decision, a quirk, a warning) does
the comment stay.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-development` (the discipline), `code-review` (this
  contract is a review criterion).
- Wiki concept: `software-architecture-principles.md` (the "Self-documenting
  code" section this skill generalizes).
