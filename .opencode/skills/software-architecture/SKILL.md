---
name: software-architecture
description: The user's software architecture contract — hexagonal-flavored layering for any Object Oriented language, driven by the lean guardrail (build lean, Rule of Three, concepts inform not dictate). Covers ports & adapters, the UI/core/infrastructure split, action objects as the use-case seam (actions carry the logic), where logic lives (actions, domain services, pure calculations), modular monolith, and SOLID/IoC. Language-agnostic with pseudocode; the Laravel and Filament expressions are separate skills. Use when designing, building, extending, or reviewing the architecture of any OO codebase, or when deciding how to structure a module, layer, or use case.
---

# software-architecture

The user's standard for how software is architected, in any Object Oriented
language. This is the _how we do it here_ contract. The _why_ lives in the
wiki concepts (`~/Documents/Obsidian/AI/wiki/concepts/`):
`architecturally-evident-structure.md`, `ddd.md`,
`hexagonal-architecture.md`, `action-objects.md`, `modular-monolith.md`,
`software-architecture-principles.md`. Load those for the reasoning; this
skill is the contract.

Concrete expressions: `laravel` (Laravel mechanics), `filament` (Filament UI
mechanics).

## When to use

- Designing, building, extending, or reviewing the architecture of any OO
  codebase.
- Deciding how to structure a module, layer, or use case.
- The user references hexagonal architecture, action objects, DTOs, bounded
  contexts, or the lean guardrail.

## Core principles

1. **Lean first (YAGNI).** Only build what's needed; only abstract after
   duplication (Rule of Three). Concepts inform judgment, they don't dictate
   it.
2. **Convention over invention.** Follow the language's standards and the
   ecosystem's established tools; minimize custom rules.
3. **Hexagonal layering.** Core domain logic isolated from the outside world;
   dependencies point inward.
4. **Actions carry the logic.** Every user story is an action (invokable use
   case taking a DTO); actions compose actions. Logic never smears into
   orchestrators, models, or service-ish grab-bags.
5. **Modular monolith.** One deployable, internally divided into modules
   (bounded contexts) with explicit boundaries and owned data.
6. **Pragmatic DDD-lite.** Use the parts that earn their keep; skip the rest
   until there's a real need.
7. **Names state domain + role.** Every name carries its domain concept and
   its architectural role (stereotype); the role locates the class (folder,
   dependencies, invocation). No metaphor names (Engine, Manager, Helper,
   Handler, Util). One class per file; lean files.

## The lean guardrail (the decision heuristic)

Before adding any architectural element (a repository, a port, a value object,
a service, a module), ask:

1. **Is there a real need?** Multiple entry points? A seam to protect? Logic
   worth isolating?
2. **Has duplication occurred?** Abstract after the 2nd–3rd repetition, not
   before.
3. **Does it reduce complexity, or add ceremony?** If it adds a layer without
   adding clarity, skip it.
4. **Does the framework already provide this?** If the ecosystem's conventions
   already carry it, don't rebuild it.

If the answer to all is "no / not yet," don't add it. The absence of a pattern
in the codebase is not evidence it's out of context — it may simply not have
been needed yet.

## Where logic lives (the placement table)

Every piece of logic has exactly one right home:

| Logic kind | Home | Rule |
|---|---|---|
| A user story | **Action** | composed out of smaller actions; one meaningful place per story |
| Logic spanning multiple entities, owned by none | **Domain service** (+ value objects) | pure, stateless, no I/O; consulted by a use case, never the reverse |
| A trivial calculation (VAT, hashing, diffing) | **Pure class/function beside the actions** | no DI, no I/O; a total function |
| Delivery mechanics (timers, event subscription, queues, debounce) | **Driving-side infrastructure** | turns ambient triggers into action invocations; zero decisions |
| Raw external data ↔ domain | **Adapters, at the boundary** | an anti-corruption layer: map raw responses onto DTOs; the core never sees provider shapes |
| State-specific behavior | **Rich enums / state pattern** | when states multiply; not before |
| Queries | **Query builders / read models** | models stay dumb data + identity |

Anti-patterns: a **god object** (an "Engine"/"Manager" accumulating
decisions); a "Service" layer duplicating what actions already do; business
logic in jobs/listeners (infrastructure *around* actions, never logic
holders); logic smeared across controller + model + job + listener.

## File organization & naming (one concern per file)

Grounded in Graça's architecturally evident structure
(`wiki/concepts/architecturally-evident-structure.md`) and the Stitcher
*Laravel Beyond CRUD* study
(`wiki/sources/stitcherio-laravel-beyond-crud.md`). The reference
implementations are the **laravel-module-\*** packages — self-contained
components with the shared kernel as its own package
(`laravel-module-support`); when in doubt, mirror them.

### The two axes of a name

Every artefact name carries two meanings, and both must be evident:

- **Domain concept** — the bounded-context concept it serves (`Invoice`,
  `Task`, `Board`). Decides *which module* it belongs to.
- **Role** — the architectural stereotype it instantiates (use case, port,
  adapter, payload, error, mapper, …). Decides *which folder it lives in*,
  *what it may depend on*, *how it is invoked*, and *its suffix*.

`InvoiceRepository`: `Invoice` is the domain, `Repository` is the role. The
role suffix exists to make name collisions impossible at scale
(`CreateInvoice` alone could be a controller, command, job, or request) and
to make classes findable by role. Long names are fine; clarity wins; the
IDE handles typing.

**The carve-out:** not every artefact gets a suffix. Domain-model classes
are the model itself — `Post`, never `PostEntity`: inside the domain layer
"entity" is the default, so the suffix locates nothing and is noise. A
suffix earns its place when the role is *not* the default for its layer.

### What a "technical role" is

A **role** (Graça's term; formally an *architectural stereotype*) is the
kind of responsibility an artefact carries in the architecture — what it
*is*, independent of the domain concept it serves. The role vocabulary
comes from the tactical patterns: DDD's building blocks (Entity, Value
Object, Repository, Factory, Service, Domain Event), hexagonal's
Port/Adapter/use case, and pattern participant roles (Mapper, Decoder,
Scheduler). UML expresses the same idea as a stereotype; Jacobson's
Boundary/Control/Entity and Larman's archetypes are the classic examples.

**The test:** a word is a role when it *locates the class* — it answers
which folder the class lives in, what it may depend on, and how it is
invoked. If a word changes none of those answers, it is not a role:
`Entity` is noise; `Manager`/`Helper`/`Util` are metaphors that name no
responsibility. Both are banned.

### One class per file

- **One class/interface per file.** The file name matches the symbol exactly:
  `CreateTaskNoteAction.ts` exports `CreateTaskNoteAction`, nothing else. An
  action's private input interface may share its file; anything consumed
  elsewhere gets its own.
- **The role is the suffix** — in the filename and the symbol name:

  | Role                      | Suffix   | Example               |
  |---------------------------|----------|-----------------------|
  | Use case                  | `Action` | `PromoteCardAction`   |
  | Core-designed interface   | `Port`   | `VaultPort`           |
  | Tool wrapper              | `Adapter`| `GitHubAdapter`       |
  | Boundary payload          | `Data`   | `TaskData`            |
  | Error                     | `Error`  | `DomainError`         |

  Supporting classes take a descriptive role word instead (Mapper, Parser,
  Resolver, Scheduler, Registry, Decoder): `TaskNoteMapper`, `SyncScheduler`,
  `ChunkedDecoder`.
- **Pure functions are lowercase function-files** named after the function:
  `hash.ts`, `boardStatus.ts`, `folderChainForPath.ts`. No suffix, no class
  wrapper. Class-internal helpers (step-down private functions serving one
  class) stay in that class's file.

### Folders: concept → architecture → role

Directory structure runs along three axes, in this order — **package by
component** (Simon Brown), with the layers as the fine-grained axis inside
each component:

1. **Concept** (top): modules/packages are the components — bounded
   contexts. One module per business concept; the top level **screams the
   domain**, not the framework. The shared kernel is itself a module
   (`laravel-module-support` in the Laravel expression).
2. **Architecture** (middle): inside a module, the layers — `App/`
   (driving), `Domain/` (core), `Infrastructure/` (driven; empty until a
   real adapter exists).
3. **Role** (leaf): inside a layer, folders per role — the menu below.

**The growth rule (when additional folders are warranted):** start flat and
group as the need arises — *"it is overzealous to create a folder to put
just one class in it"* (Graça). A role folder appears when a **second class
of that role** exists; the taxonomy is a menu, not an upfront scaffold.
When one business concept comes to dominate a role folder, split by concept
*inside* the role folder — or, if the concept has outgrown the module, that
is the signal to extract it into its own module. At the leaf, grouping by
subject or by role both work; the choice is cheap to change later. Every
split serves one target: **high cohesion** within a folder, **low coupling**
across them.

**The role menu** (closed; extend only by decision, never per repo):

| Layer          | Roles |
|----------------|-------|
| Domain (core)  | `Actions/` (`Action`), `Ports/` (`Port`), `DataTransferObjects/` (`Data`), `Enums/` (descriptive: `PostStatus`), `Models/` (bare), `Errors/` (`Error`), `Queries/` (`Query`), `Collections/` (`Collection`), `Events/` (`Event`), `Exceptions/` (descriptive), `Rules/` (`Rule`), `States/` (`State`), domain services (`Service`) |
| App (driving)  | `Commands/`, `Controllers/`, `Requests/`, `Resources/`, `Middleware/`, `Filters/`, `ViewModels/`, `Scheduling/` |
| Infrastructure | `Infrastructure/<Tool>/` (`Adapter`) — one subfolder per tool; a second vendor adapter earns a per-vendor subfolder |

A **port is rarely just an interface**: it may carry the value objects,
DTOs, builders, and query objects the core needs to use the tool — all of
that lives with the port.

**Support, not Utils.** A `Support/` folder is legitimate for **generic,
universal concepts** — code that could have been part of the framework or
language (Graça's userland extensions; Brent's `Support\` namespace).
Everything admitted must be conceptually cohesive, and Support is a staging
area: when a cluster matures, extract it into its own component/package.
What is banned is the grab-bag — a `Utils/`/`Commons/` folder where misfit
code is dumped with no conceptual meaning; that is the first step toward a
**big ball of mud**. When unsure where code goes, the answer is one of: its
proper role folder (domain-specific), `Support/` (generic and cohesive),
the shared kernel (already extracted, shared across modules), or it doesn't
exist yet.

### Boundary rules

- **The application's subject is not a component.** If the whole app is a
  shop, `Shop` is not a module — its parts (`Owner`, `Products`) are.
- **Applications don't talk to each other.** Each driving surface (HTTP,
  CLI, API) consumes the domain; they never call each other.
- **Handler vs listener placement:** a command handler lives next to the
  one command that triggers it; an event listener never lives next to the
  event (events have several triggers and several listeners).
- **Repository sizing:** one repository per entity per data source
  (occasionally per aggregate); never one gateway per database; never per
  use case. Placement is a project choice: repository-as-adapter
  (implementation in Infrastructure) or repositories in the application
  layer behind a persistence port.
- **Structure iterates.** Domains are carved, then refactored — a domain
  that outgrows grasp splits. Domain code has few dependencies, so moving
  is cheap; don't fear starting, fear not refactoring.
- **Ports carry their rationale**: a short comment stating the core's need —
  designed for the core, never mimicking the tool's API.
- **A repo that is itself a single adapter** (a thin skin over one external
  tool, no business logic) does not get the three-folder shape — that would
  be ceremony. Flat structure, classes + role suffixes, pure function-files.

## Hexagonal architecture (ports & adapters)

The core connects to the outside world only through **ports** (interfaces,
designed for the core's needs — never mimicking a tool's API) implemented by
**adapters** (classes wrapping concrete tools).

- **Driving adapters** *start* actions on the core (UI, CLI, commands,
  schedulers). Both the port and its implementation (the use case) belong
  inside the application.
- **Driven adapters** are *told* by the core (database, external APIs). The
  port belongs inside the application; the implementation belongs outside,
  wrapping the external tool.

Dependencies point **inward** — the **dependency rule**: the domain layer
knows nothing about the application layer; the core knows nothing about
adapters.

Folder shape inside a module (architecturally evident coding; the module
itself is the component — see "Modular monolith"):

```
src/
├── App/               # driving side (controllers, commands, schedulers, UI)
├── Domain/            # core: actions, DTOs, enums, models, domain services
└── Infrastructure/    # driven adapters (empty until there's a real need)
```

Enforce with a dependency-graph tool (e.g. Deptrac in PHP) in CI: allowed
dependencies between layers, build fails on violation. This is what keeps
the structure from **architectural drift** — the structure decays one
import at a time unless a gate rejects it.

## Action objects (the use-case seam)

Each meaningful business operation is its own class — a **transaction
script** (Fowler) in command-pattern shape: single responsibility,
immutable, one public method (`invoke()` / `execute()` — language-idiomatic),
input as a payload/DTO, dependencies via constructor injection (never
resolved inside the body). An action composes zero or more nested actions,
each with its own single responsibility.

```text
final class CreatePostAction
    constructor(RecordPostCreatedAction auditTrail)

    invoke(PostData data) -> Post
        transaction:
            post = Post.create(author_id: data.authorId, title: data.title, ...)
            auditTrail(post)
            return post
```

Sizing and composition rules (Stitcher, Laravel Beyond CRUD):

- Split actions small enough to reuse, large enough not to drown in them.
- Prefer copy-paste over premature abstraction; abstract by functionality,
  never by technical properties.
- Compose via constructor injection; avoid deep dependency chains.
- The primary payoff is cognitive load, not reusability: when a story
  changes, there is one meaningful place to go — the alternative is
  **shotgun surgery** (one story change, N files to touch).
- Rejected as overkill at this scale: command/handler buses, event-driven
  architectures.

### State via enums + guards

Rich enums guard their own transitions:

```text
enum PostStatus
    Draft, Published, Scheduled

    canTransitionTo(next) -> bool
    transitionTo(next) -> PostStatus   # throws DomainException on invalid move
```

The action wraps `transitionTo()` in a try/catch, translating the
`DomainException` into a domain-specific exception — never imperative
`throw_unless` helpers.

## Modular monolith

One deployable, internally divided into **modules with explicit boundaries**.
The module **is** Graça's component: a bounded context made visible as a
package. In the Laravel expression, modules are Composer packages and the
shared kernel is itself a module (`laravel-module-support`).

- **Module** — a self-contained unit with a clear boundary (a bounded
  context); exposes a defined API, internals private.
- **Owned data** — each module owns its data/schema and is its **single
  source of truth**; others don't reach in. A module may query data it
  doesn't own (read-only) but only changes data it owns.
- **Communication** — via contracts (events, actions), not direct coupling.
- **Extractable** — the boundary makes a later service split possible.

## Architectural patterns (when they earn their keep)

- **Event-driven** — decoupling components, side effects, history. Not for
  simple synchronous flows.
- **CQRS / CQS** — light only: split at the controller level (reads hit
  model/query builders directly; writes always go through an action). Strict
  CQRS is overkill for CRUD apps.
- **Event sourcing** — audit-critical domains only (finance, compliance).
- **Repository** — only when swapping storage or testing the domain without
  a DB; otherwise ceremony.
- **Service layer** — don't. Actions already are the use-case layer. Domain
  services are different (see "Where logic lives").
- **Saga / process manager** — distributed transactions or multi-step
  processes with rollback only.

## SOLID, DRY, IoC (as judgment, not dogma)

- **SRP** drives action objects: one class, one reason to change.
- **DRY** is tempered by the Rule of Three.
- **DI** is always constructor injection.
- **Law of Demeter** and **composition over inheritance** apply as judgment.

## The working agreement (pushback)

The user wants a common conception of good software architecture — a
ubiquitous language for pair programming. In exchange, the agent is expected
to **push back on architecture when the context warrants it**, not just apply
conventions. When a convention would hurt in a given context, say so.

## Related

- **Loads:** (none — this is a leaf contract)
- **References:** `laravel` (the Laravel expression), `filament` (the Filament
  expression), `software-testing` (how the layers are tested).
- Wiki concepts: `architecturally-evident-structure.md` (the folder taxonomy
  this section distills), `ddd.md`, `hexagonal-architecture.md`,
  `action-objects.md`, `modular-monolith.md`,
  `software-architecture-principles.md`.
