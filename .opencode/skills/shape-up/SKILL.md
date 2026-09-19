---
name: shape-up
description: The user's Shape Up working method — shaping work before betting on it, appetites, hills, and slice sizing. Used for project management and client work that requires estimates and advanced shaping ahead of time. Use when shaping a piece of work, setting an appetite, betting on a cycle, tracking a hill, or sizing a slice.
---

# shape-up

The user's working method for project management and client work: **Shape Up**
(Basecamp's methodology by Ryan Singer). Work is **shaped** before it's bet on,
each bet has an **appetite** (a time budget), progress is tracked on a **hill**,
and delivery happens in **slices**.

This is the methodology. The GitHub mechanics (labels, project template) are
codified in `new-project` and the `.github` repo; this skill is the way of
working.

## When to use

- Shaping a piece of work before committing to it.
- Setting an appetite for a bet.
- Betting on a cycle.
- Tracking progress on a hill.
- Sizing a slice.
- Client work that requires estimates and advanced shaping ahead of time.

## Core concepts

### Shaping

Shaping is the work of turning a raw idea into a **shaped bet**: a concrete,
bounded piece of work with a clear scope, before any code is written. A shaped
bet answers: what are we building, what's out of scope, and how will we know
it's done.

- **Pitch** — the shaped proposal: the problem, the solution, the appetite, the
  rabbit holes to avoid.
- **Appetite** — the time budget for the bet (e.g. 2 weeks, 6 weeks). Not an
  estimate of effort; a cap on how much time you're willing to spend.
- **Rabbit holes** — the traps to avoid; shaping names them so the builder
  doesn't fall in.

### Betting

A **bet** is a commitment to spend a fixed appetite on a shaped pitch. Unlike a
backlog, a bet is a decision: this work, this cycle, this budget. Work that
isn't bet on isn't scheduled.

### The hill

Progress is tracked on a **hill** (two phases):

- **Uphill** — figuring it out: the unknown, the design, the hard part.
- **Downhill** — executing it: the known, the implementation.

A task moves uphill as it's being figured out and downhill once the approach is
clear. The hill makes progress visible and honest — "we're still uphill" means
the approach isn't settled yet.

### Slices

Work is delivered in **slices**: vertical, end-to-end pieces that each deliver
value, rather than horizontal layers (all the UI, then all the logic). A slice
is a thin, shippable unit. Slicing keeps each bet shippable and reduces risk.

## The workflow

1. **Shape** — turn the idea into a pitch: problem, solution, appetite, rabbit
   holes. Do the thinking up front so the builder doesn't have to.
2. **Bet** — decide to spend the appetite on the pitch for a cycle.
3. **Build** — execute in slices, tracking progress on the hill.
4. **Deliver** — ship the slices; the bet is done when the appetite is spent or
   the work is delivered.

## Labels and project fields

The GitHub mechanics that support this:

- **Labels** — `type: slice`, `type: pitch`, `type: task`, `type: bug`,
  `type: chore` (canonical set, source of truth in `.github`).
- **Project fields** — Stage, Work type, Appetite, Hill, Start, End (the Shape
  Up project template, #9 `.github`).

## Related

- **Loads:** (none — loaded on demand)
- **References:** `new-project` (the labels + project template mechanics),
  `github` (the platform interface), `wayfinder` (planning complex work).
