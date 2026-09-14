---
name: software-architecture
description: The user's software architecture contract — hexagonal-flavored layering for any Object Oriented language, driven by the lean guardrail (build lean, Rule of Three, concepts inform not dictate). Covers ports & adapters, the UI/core/infrastructure split, action objects as the use-case seam (actions carry the logic), where logic lives (actions, domain services, pure calculations), modular monolith, and SOLID/IoC. Language-agnostic with pseudocode; the Laravel and Filament expressions are separate skills. Use when designing, building, extending, or reviewing the architecture of any OO codebase, or when deciding how to structure a module, layer, or use case.
---

# software-architecture

The user's standard for how software is architected, in any Object Oriented
language. This is the _how we do it here_ contract. The _why_ lives in the
wiki concepts (`~/Documents/Obsidian/AI/wiki/concepts/`): `ddd.md`,
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

1. **Lean first.** Only build what's needed; only abstract after duplication
   (Rule of Three). Concepts inform judgment, they don't dictate it.
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
7. **Names state responsibility.** No metaphor names (Engine, Manager,
   Helper, Handler, Util). One class per entry point; lean files.

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
| Raw external data ↔ domain | **Adapters, at the boundary** | map raw responses onto DTOs; the core never sees provider shapes |
| State-specific behavior | **Rich enums / state pattern** | when states multiply; not before |
| Queries | **Query builders / read models** | models stay dumb data + identity |

Anti-patterns: an "Engine"/"Manager" class that accumulates decisions; a
"Service" layer duplicating what actions already do; business logic in
jobs/listeners (infrastructure *around* actions, never logic holders); logic
smeared across controller + model + job + listener.

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

Dependencies point **inward**: the domain layer knows nothing about the
application layer; the core knows nothing about adapters.

Folder shape at the source root (architecturally evident coding):

```
src/
├── App/               # driving side (controllers, commands, schedulers, UI)
├── Domain/            # core: actions, DTOs, enums, models, domain services
└── Infrastructure/    # driven adapters (empty until there's a real need)
```

Enforce with a dependency-graph tool (e.g. Deptrac in PHP) in CI: allowed
dependencies between layers, build fails on violation.

## Action objects (the use-case seam)

Each meaningful business operation is its own class: single responsibility,
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
  changes, there is one meaningful place to go.
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

One deployable, internally divided into **modules with explicit boundaries**:

- **Module** — a self-contained unit with a clear boundary (a bounded
  context); exposes a defined API, internals private.
- **Owned data** — each module owns its data/schema; others don't reach in.
  A module may query data it doesn't own (read-only) but only changes data
  it owns.
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
- Wiki concepts: `ddd.md`, `hexagonal-architecture.md`, `action-objects.md`,
  `modular-monolith.md`, `software-architecture-principles.md`.
