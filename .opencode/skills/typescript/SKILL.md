---
name: typescript
description: The user's TypeScript and Node conventions — the TS expression of the software-architecture contract, so the agent writes TS/Node in the house style rather than generic defaults. Use when writing, extending, or reviewing TypeScript or Node code, naming an interface or type, deciding a module's export shape, or wiring dependencies.
metadata:
  category: language
  route-when: "Use when writing, extending, or reviewing TypeScript or Node code, naming an interface or type, deciding a module's export shape, wiring dependencies, or configuring tsconfig."
---

# typescript

The TypeScript and Node expression of the `software-architecture` contract.
Read them together: this skill says how the contract looks in TS/Node; the
contract itself (layers, roles, DTOs, the lean guardrail) lives in
`software-architecture`.

This skill carries only what a TypeScript/Node agent would otherwise get wrong
— our deviations from the common TS prior. It does not restate the language.

## Related

- **Loads:** `software-architecture` (the contract this expresses).
- **References:** `software-testing` (Vitest), `obsidian-plugin` (plugin
  packaging and release).

## Interface naming: the role is the suffix, never the construct

An interface carries the same role suffix as any other artefact — a port is
`XPort`, a payload is `XDataTransferObject`, an error is `XError`. It never
carries a marker of the *language construct*:

- **No `I` prefix.** `IPostRepository` is a C#-ism: it names the construct, not
  the role. Java and TypeScript do not mark interfaces in the name.
- **No `Interface` suffix.** `PostRepositoryInterface` restates the construct
  and throws the role away. Graça's explicit-architecture uses the `Interface`
  suffix; we do not.

Why: our names state domain + role, and the role locates the file, its
dependencies, and its invocation. "It is an interface" is a TypeScript detail —
structural typing erases it at runtime — so it is not worth a name. A reader
should not be able to tell a class from an interface by its name.

```ts
// yes — role suffix, construct-agnostic
export interface MirrorPort { /* ... */ }
export interface CodeHostResponse { status: number; json: unknown }

// no — construct markers
export interface IMirrorPort { /* ... */ }
export interface MirrorPortInterface { /* ... */ }
```

An interface with no natural role word (`CodeHostTransport`,
`SyncProjectDependencies`) gets a role word, or is treated as a carve-out like
a domain model — never padded with `I`/`Interface` to mark it.

## Module system (ESM / NodeNext)

Local imports use explicit `.js` specifiers that resolve onto `.ts` sources —
NodeNext requires the emitted extension in the specifier, so a `.ts` file
imports its sibling as `./sibling.js`. Type-only imports use `import type`, so
the bundler can elide them.

```ts
import { mergeField } from './mergeField.js';
import type { SideObservation } from './SideObservation.js';
```

## No barrel files

Do not add `index.ts` re-export barrels. Import from the module's own path.

A barrel looks tidy and behaves badly here: re-exporting a folder's modules
lets two folders that reference each other form a cycle *through the barrels*.
Barrelling the three core folders took the codebase from 1 circular dependency
to 27; the bundle was byte-identical and the import-statement count did not move
(rewriting a path does not merge import statements). It also collides with the
role-folder naming gate, which rejects a bare `index.ts` in a role folder.

The benefit a barrel promises — a folder's public surface — is better bought
with cohesion: if a folder needs a front door, it has too many cross-folder
imports, and the fix is to reduce them, not to hide them. Explicit paths are
the price of a cycle-free, legible graph, and the path is what locates the
module.

(Leaf folders whose only consumers are the composition root are the one safe
case — they form no cycle — but the payoff is near-zero and not worth a
convention.)

## Dependency injection: constructor only, one composition root

No DI container, no decorators. Dependencies arrive through the constructor and
are never resolved inside a method body.

```ts
export class SyncProjectAction {
  constructor(private readonly deps: SyncProjectDependencies) {}

  async execute(project: string): Promise<unknown[]> {
    // uses this.deps only — nothing is resolved here
  }
}
```

All wiring happens in **one** composition root — the entry point
(`src/main.ts`). Do not construct instances at module scope or in a per-folder
barrel: a scattered construction site is a second composition root and defeats
the point of having one.

## tsconfig baseline

`strict`, plus the checks that catch real bugs: `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `noUnusedLocals`, `noUnusedParameters`,
`noImplicitOverride`, `noFallthroughCasesInSwitch`, `noImplicitReturns`.
`module`/`moduleResolution`: `NodeNext`. Path aliases are allowed to shorten
deep relative specifiers (`@core/...`); they are not a licence for barrels.

## Gates

The TypeScript repos enforce the architecture mechanically: an ESLint
boundaries matrix (allowed module edges) and a role-folder naming gate, run
alongside the test suite. A convention without a gate erodes one dispatch at a
time.

