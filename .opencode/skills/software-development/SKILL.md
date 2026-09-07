---
name: software-development
description: The user's software development discipline — how code changes are made, verified, and kept clean. Incremental atomic changes, verify-as-you-go, cleanup-as-you-go (no dangling code), and a definition of done. Applies to every software development context (any language, framework, or repo). Use when building, extending, refactoring, or reviewing code, or when deciding how to structure a change.
---

# software-development

The user's standard for how code changes are made and committed. The goal: no
dangling code, no messy history, no "cleanup later" debt. Cleanup is part of
the work, not a follow-up task.

This skill is language- and framework-agnostic. Git mechanics (committing,
squashing, history hygiene) live in the `git-workflow` skill; this one covers
the discipline that applies before and during any code change.

## Work incrementally and atomically

- **One concern per change.** A change is a single coherent unit: one feature,
  one fix, one refactor. If a task spans multiple concerns, split it into
  sequential changes — never one change that mixes them.
- **Verify as you go.** After each change, run the project's checks
  (typecheck, tests, build, lint) before moving on. A change that doesn't
  verify is not done.
- **Commit early, commit often.** A verified unit of work gets committed
  immediately. Don't accumulate uncommitted work across multiple concerns.

## Clean up as you go (the anti-dangling rule)

When a change supersedes or invalidates existing code, remove the dead code
**in the same change** — not later:

- **Removed a call site?** Delete the now-unused function, type, import, or
  parameter in the same change.
- **Changed a design direction?** Delete the code the old direction left
  behind (dead branches, unused helpers, superseded modules) in the same
  change.
- **Changed a contract?** Update callers, docs, and config in the same change.
- **After each change, grep for dangling references** to anything you renamed
  or removed: `grep -rn "<removed-symbol>" src/`. A symbol with no callers is
  dead — remove it or justify keeping it.

The test: **after every change, the tree should contain no code that isn't
reachable from a live entry point, and no docs that describe behavior that
doesn't exist.**

## Verify the whole before committing

Before committing a change:

1. Run the project's checks (typecheck, tests, build, lint).
2. Grep for dangling references to renamed/removed symbols.
3. Review the diff — does it contain only this change's concern?
4. Update docs (README, comments) that the change affects, in the same change.

## The user's definition of done

A change is done when:

- [ ] It works (verified by running it)
- [ ] It's atomic (one concern, one change)
- [ ] It's clean (no dead code, no dangling references, docs updated)
- [ ] It's committed with a clear Conventional Commit message
- [ ] History is squashed by feature before push (if it spanned multiple
      commits)