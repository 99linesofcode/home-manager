---
name: activepieces
description: Build and extend Activepieces pieces (integrations) to the platform's conventions — piece anatomy, auth in lib/auth.ts, actions and triggers, the build/register/verify loop, and the seam that keeps domain logic in the core rather than the piece. Use when building, extending, or reviewing an Activepieces piece, connector, action, or trigger.
metadata:
  category: tooling
  route-when: "Use when building, extending, or reviewing an Activepieces piece, its actions, its triggers, or a flow that wires Activepieces to a service."
  route-not-when: "Use `software-architecture` for where the logic lives inside the core the piece calls, and `typescript` for the language conventions."
---

# Skill: activepieces

The contract for developing Activepieces pieces in the house style. Load it
whenever work touches a piece, a connector, an action, a trigger, or a flow.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-architecture` (where the core's logic lives),
  `typescript` (the language conventions a piece follows).

## What a piece is

A **piece** is an integration — a set of *actions* (operations a flow can
perform) and *triggers* (events that start a flow) for one service. At heart it
is a standard npm package that exports a `Piece`.

A piece's source imports Activepieces' own workspace libraries
(`@activepieces/pieces-framework` and friends), which are not published to npm,
so a piece is **built inside the Activepieces monorepo**:

- `packages/pieces/custom/<name>/` — a private, organisation-specific piece.
- `packages/pieces/community/<name>/` — a piece meant to be shared.

The build inlines those libraries into a **self-contained bundle**, which
reaches a running instance as an npm package or a `.tgz` upload and is installed
as a *custom* or *private* piece. The user self-hosts Activepieces.

## Anatomy

```
packages/pieces/<kind>/<name>/
  src/
    index.ts            # createPiece: auth + actions + triggers
    lib/
      auth.ts           # auth ALWAYS lives here, never inline in index.ts
      actions/          # one file per action
      triggers/         # one file per trigger
      common/           # shared API helpers, dropdown props (optional)
  package.json
  .eslintrc.json
  tsconfig.json
  tsconfig.lib.json
```

## The shape of a piece

```
piece <name>:
  auth:     <SecretText | OAuth2 | BasicAuth | CustomAuth | None>
  actions:  [<action>, …]
  triggers: [<trigger>, …]

action <name>:
  props:    <the inputs a user fills in the flow builder>
  run(ctx): <marshal input → call the service or the core → return a flattened result>

trigger <name>:
  type:     <POLLING | WEBHOOK>
  run(ctx): <return the items created since the last poll>
```

Auth lives in `lib/auth.ts` and is exported from `index.ts` so actions and
triggers import it. It is one of the `PieceAuth` constructors: `SecretText` (an
API key, read as `ctx.auth`), `OAuth2` (`ctx.auth.access_token`), `BasicAuth`
(`.username` / `.password`), `CustomAuth` (named fields), or `None`.

## Rules that bite

- **A component's `name` is permanent** — it must never change after publish.
- **Every trigger needs sample data**, even an empty object.
- **Build and lint must both pass** — a lint failure blocks CI even when the
  build is green.

## Build and register

The Activepieces monorepo uses **bun** as its package manager and **turbo** as
its task runner, so a piece inherits them by living there. That is a property of
*their* repository, not a house convention — the core a piece calls keeps
whatever toolchain its own repo uses.

Two requirements of their repo:

1. **Register the piece** in the repo-root path map (`tsconfig.base.json`,
   `compilerOptions.paths`), **alphabetically** — the build cannot resolve it
   otherwise.
2. **Load it in a dev instance** through the repo's dev-piece environment
   variable.

The piece's own compile step is plain `tsc`; the task runner only orchestrates
across the monorepo. The repository ships a `piece-builder` agent skill
(`.agents/skills/piece-builder`) with the vetted component patterns — read it
before writing a component.

## The seam: a piece is an adapter, not a home

A piece is a **driving adapter**. It marshals a flow's input into a call and
marshals the result back out. Domain and classification logic stays in the core
the piece calls, so it is testable without Activepieces and reusable outside it.
Never grow domain rules inside a piece.

## Reuse the built-in pieces

Check what already ships before building anything:

- **Gmail** — `New Email`, `New Labeled Email`, `New Attachment`, and `New
  Label` triggers; `Add Label to Email`, `Remove Label from Email`, `Create
  Label`, `Archive Email`, `Delete Email`, `Get Email`, and `Search Mail`
  actions; plus a raw Gmail-API custom-call action.
- **OpenRouter** — chat completions only.

The OpenRouter piece speaks the chat-completions API, so it **cannot** reach a
typed decision endpoint (Jev's `/api/alpha/decisions`). A typed-decision call
needs a custom piece, or the raw custom-API-call action.

## Conventions

- Flatten nested API responses in a component's output; declare an output schema
  when the output is keyed by opaque ids or returned as arrays.
- Read `ux-guidelines.md` and `output-quality.md` from the `piece-builder` skill
  before implementing any component — they apply to every action and trigger.
