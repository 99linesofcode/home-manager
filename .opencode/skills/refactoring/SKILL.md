---
name: refactoring
description: Restructure code without changing behaviour, at snippet, unit, or system scale. Use when a change's main job is to improve legibility rather than add behaviour.
metadata:
  category: architecture
  route-when: "Use when a change's main job is a behaviour-preserving restructure of code, at any scale, including when deciding how much machinery the refactor deserves."
  route-not-when: "Use `premise-demolition` when the whole system or a module's architecture is in question and the shape itself is being judged."
---

# refactoring

Restructuring code without changing behaviour, at any scale. The scale decides
the machinery; legibility is the bar and the judge. A refactor that reaches for
the wrong scale's machinery is a defect, however clean the result looks.

## Related

- **Loads:** (none — loaded on demand).
- **References:** `premise-demolition` (the system-scale path), `systems-thinking`
  (the whole-system lens), `software-testing` (characterization tests),
  `code-review` (the findings format and the finding tags),
  `software-architecture` (where logic lives), `clean-code` (the principles the
  result is judged by).

## Files

| File | Load | Read when |
|---|---|---|
| `references/catalogue.md` | on-demand | when choosing which refactoring to apply |

## When to use

- A change whose main job is to restructure code without changing behaviour.
- "Clean this up", "this is hard to read", "make this legible",
  "behaviour-preserving".
- Deciding how much machinery a refactor deserves.

## The operations

A refactor is a sequence of **named operations** from the catalogue
(`references/catalogue.md`) — Extract Function, Combine Functions into Class,
Pull Up Method, Replace Nested Conditional with Guard Clauses, and the rest.
Name the operation you are applying, apply one at a time, and keep every step
green.

- **Group related concepts — never one helper per file.** `Combine Functions
  into Class` is the operation: several functions that work on the same data are
  a class waiting to be born. A single trivial helper is not; it stays beside
  what it serves.
- **Shared across classes → pull up.** When the same function or field is needed
  by more than one class, `Pull Up Method` / `Pull Up Field` (or `Extract
  Superclass`, or a shared module where inheritance does not fit) — never a copy
  per class.
- **No abstraction for one caller** unless its name states a step of intent.

## Scale decides the machinery

Identify the scale before touching code. The scale — not the effort — names the
process. When torn between two scales, take the larger.

| Scale | Scope | Machinery |
|---|---|---|
| **Snippet** | A few lines, one expression, a rename. | One worker, a light brief. No characterization tests — the change is local and reviewable by eye. |
| **Unit** | One file or one module. | Characterization tests first (pin the current behaviour at the unit's boundary), then behaviour-preserving steps, each landing green. |
| **System** | A whole system, or a module's architecture where the shape itself is in question. | A premise audit by a fresh-context role (`premise-demolition`, `systems-thinking`) — never done in the anchored context. |

## The legibility lens (the concrete tests)

Legibility is the bar and the judge. Four tests, each a question a cold reader
answers:

1. Can a cold reader state what this does in one sentence?
2. Is the next change local (one place to go), or does it reach across the code?
3. Do the names carry intent, or do they carry mechanism?
4. Would removing an abstraction make it clearer? If yes, remove it.

A refactor that fails a test is not done.

## Duplication policy

- **Duplication with different reasons to change is kept.** Two similar blocks
  that will change for different reasons are not a DRY violation.
- **Same input and output, different body — keep both.** Two functions whose
  signature and result are identical are still not a duplication to collapse
  when their **bodies differ**: the differing body is the reason they will
  change apart. Consolidate only when the bodies are byte-identical; when they
  differ at all, however equivalent the behaviour, leave both.
- **An abstraction with one caller is allowed when it names a step of intent.**
  A named step reads better than the inline block.
- **Inline an abstraction whose name adds nothing.** A name that restates the
  mechanism is noise.

## Tag every finding

Every finding a refactor produces is tagged by what it protects:

- **intent** — the change makes intent clearer or preserves it.
- **correctness** — the change affects behaviour or risk.
- **convention-only** — the change only matches a house convention.

Convention-only findings are **non-blocking unless the fix pays for itself** (the
change is small, local, and clearly better). Never block a refactor on a
convention-only finding. `code-review` owns the findings format.

## Behaviour preservation

At unit and system scale, characterization tests come first; every step lands
green; the refactor changes structure, not behaviour. See `software-testing`.

## Must not

- Redesign at snippet scale.
- Skip characterization tests at unit scale.
- Perform a system-scale audit in the anchored context.
- Block on convention-only findings.
- Change behaviour under the name of a refactor.
