---
name: software-architecture
description: Architecture contract for any OO codebase — where logic lives (actions, domain services, pure calculations), hexagonal ports & adapters, canonical DTOs (the core owns its shapes; one per concept), provider neutrality, the lean guardrail, the modular monolith, ARCHITECTURE.md. Use when designing, building or reviewing architecture, placing logic, or defining a port, DTO or use case. Load `software-architecture-structure` for folders, naming and role suffixes.
metadata:
  category: architecture
  route-when: "Use when designing, building, extending, or reviewing the architecture of any OO codebase, or when deciding where logic lives, how a use case is shaped, or how a port or DTO is defined."
  route-not-when: "Use `software-architecture-structure` for naming or placing a file or class, choosing a folder, or picking a role suffix."
---

# software-architecture

The user's contract for how software is architected, in any Object Oriented
language — the _how we do it here_. This is the **core**: principles, where
logic lives, the hexagonal rules, action objects, the modular monolith, and the
`ARCHITECTURE.md` contract.

**Structure and naming live in the companion skill
`software-architecture-structure`** — the folder tree, the closed role-suffix
table, one class per file. Load it before creating or moving any file. The
_why_ lives in the wiki concepts (`~/Documents/Obsidian/AI/wiki/concepts/`):
`architecturally-evident-structure.md`, `ddd.md`, `hexagonal-architecture.md`,
`action-objects.md`, `modular-monolith.md`, `software-architecture-principles.md`.

## Related

- **Loads:** `software-architecture-structure` (folders, naming, the role
  table).
- **References:** `laravel`, `filament` (the PHP expression), `rails`, `avo`
  (the Ruby expression), `typescript` (the TS/Node expression),
  `software-testing` (how the layers are tested), `project-seed` (the
  `ARCHITECTURE.md` stub), `architecture-and-skeleton` (fills it in),
  `code-review` (the architecture check), `premise-demolition` (challenging an
  existing design), `systems-thinking` (the whole-system lens).

## External

| Path | Load | Read when |
|---|---|---|
| `~/Development/laravel-module-*` | on-demand | the reference module family — mirror it where this skill is silent |
| `https://github.com/hgraca/explicit-architecture-php` | on-demand | Graça's reference implementation — mirror it where this skill is silent |
| `https://github.com/hgraca/explicit-architecture-reactjs` | on-demand | the React expression of the same reference |
| `~/Documents/Obsidian/AI/wiki/concepts/` | on-demand | for the rationale behind a rule |

Where this skill and the reference apps differ, **this skill wins** (we invert
Graça's axes — module outermost); where this skill is silent, mirror them.

## When to use

- Designing, building, extending, or reviewing the architecture of any OO
  codebase.
- Deciding where a piece of logic lives, or how a use case is shaped.
- The user references hexagonal architecture, action objects, DTOs, bounded
  contexts, provider neutrality, or the lean guardrail.

## Core principles

1. **Lean first (YAGNI).** Only build what's needed; only abstract after
   duplication (Rule of Three). Concepts inform judgment, they don't dictate
   it.
2. **Convention over configuration.** Prefer a uniform, predictable structure
   and sensible defaults over per-instance knobs; follow the language's
   standards and the ecosystem's established tools, and minimize custom rules.
   A convention everyone follows beats a configuration everyone must set.
3. **Hexagonal layering.** Core domain logic isolated from the outside world;
   dependencies point inward.
4. **Actions carry the logic.** Every user story is an action (an invokable use
   case taking a DTO); actions compose actions. Logic never smears into
   orchestrators, models, or service-ish grab-bags.
5. **Modular monolith.** One deployable, internally divided into modules
   (bounded contexts) with explicit boundaries and owned data.
6. **Pragmatic DDD-lite.** Use the parts that earn their keep; skip the rest
   until there's a real need. Models are data + identity; behaviour lives in
   actions, domain services and value objects.
7. **Names state domain + role.** Every name carries its domain concept and its
   architectural role; the role locates the class. No metaphor names (Engine,
   Manager, Helper, Handler, Util). One class per file. (Detail:
   `software-architecture-structure`.)

## Convention over configuration (the default stance)

Prefer a convention everyone follows over a configuration everyone sets. This
is the operating default for the whole setup, not just code:

- **Uniform anatomy.** Every artefact of a kind looks the same — skills,
  agents, specs, project homes, module skeletons. Predictable structure is
  cheaper than flexible structure: a reader (human or agent) finds what they
  expect without being told.
- **Sensible defaults first.** Ship a working default — agent, model,
  permissions, project layout, devshell — and let a project override it only
  where it genuinely differs.
- **Convention beats a knob.** A knob is a decision deferred to every caller;
  if a convention can absorb the case, don't expose the knob.
- **The escape hatch is explicit.** Where a project must differ, the override
  is a deliberate, visible act (a project `AGENTS.md` / config file), not a
  silent per-repo variation that erodes the convention.

Push back when a convention would genuinely hurt a given context (see "The
working agreement") — a convention is a strong default, not a straitjacket.

## The lean guardrail (the decision heuristic)

Before adding any architectural element (a repository, a port, a value object,
a service, a module), ask:

1. **Is there a real need?** Multiple entry points? A seam to protect? Logic
   worth isolating?
2. **Has duplication occurred?** Abstract after the 2nd–3rd repetition, not
   before. Duplication with different reasons to change is kept — two similar
   blocks that change for different reasons are not a DRY violation.
3. **Does it make verification cheaper, or add ceremony?** A layer earns its
   keep by making the behavior easier to verify — a seam to inject a fake, a
   boundary to test against. For an agent, every layer between the caller and
   the behavior is another file to read: a tool call and a context tax. A layer
   that buys neither verifiability nor real isolation is ceremony — skip it.
4. **Does the framework already provide this?** If the ecosystem's conventions
   already carry it, don't rebuild it.
5. **Does this make intent clearer?** A name or a seam that states a step of
   intent earns its keep even with one caller; an abstraction that hides intent
   does not.

If the answer to all is "no / not yet," don't add it. The absence of a pattern
in the codebase is not evidence it's out of context — it may simply not have
been needed yet. This is a lens, not a checklist to violate: a missing element
is not a finding by itself — a finding counts only when it harms legibility,
correctness, or intent.

## Where logic lives (the placement table)

Every piece of logic has exactly one right home:

| Logic kind | Home | Rule |
|---|---|---|
| A user story | **Action** | composed out of smaller actions; one meaningful place per story |
| Logic spanning multiple entities, owned by none | **Domain service** (+ value objects) | pure, stateless, no I/O; consulted by a use case, never the reverse |
| A trivial calculation (VAT, hashing, diffing) | **Pure class/function beside the actions** | no DI, no I/O; a total function |
| Delivery mechanics (timers, event subscription, queues, debounce) | **Driving-side infrastructure** | turns ambient triggers into action invocations; zero decisions |
| Raw external data ↔ domain | **Adapters, at the boundary** | an anti-corruption layer: map raw responses onto the domain's canonical DTOs; the core never sees provider shapes — including DTOs that mimic a provider's structure |
| State-specific behavior | **Rich enums / state pattern** | when states multiply; not before |
| Queries | **Query builders / read models** | models stay dumb data + identity |

Anti-patterns: a **god object** (an "Engine"/"Manager" accumulating
decisions); a "Service" layer duplicating what actions already do; business
logic in jobs/listeners (infrastructure *around* actions, never logic
holders); logic smeared across controller + model + job + listener.

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

**DTOs belong to the core, not the provider.** A port's DTOs are designed for
the core's needs exactly as the port itself is — never mimicking a tool's API.
"The core never sees provider shapes" includes shapes wearing a DTO costume: a
`TaskDataTransferObject` whose fields mirror a provider's issue is a provider
shape. **One canonical DTO per domain concept:** when a second adapter serves
the same concept (a second provider, a second storage, a second UI), both map
onto the SAME domain DTO — parallel per-provider DTO vocabularies are the
anti-corruption layer failing silently. The second provider is the
Rule-of-Three trigger to unify the shapes.

**The canonical test:** when two representations of the same concept must be
compared, merged, or synced, the diff logic operates on canonical fields only.
If it references provider-specific fields, the canonical model is missing.
Accumulating symptoms: per-pair diff/verdict machinery, duplicated
hash/translation helpers, provider-shaped snapshot fragments.

Dependencies point **inward** — the **dependency rule**: the domain layer knows
nothing about the application layer; the core knows nothing about adapters.
The folder shape and the layer tree are in `software-architecture-structure`.

Enforce the dependency graph with a tool (e.g. Deptrac in PHP) in CI: allowed
dependencies between layers, build fails on violation. This is what keeps the
structure from **architectural drift** — the structure decays one import at a
time unless a gate rejects it.

### Provider neutrality (the vocabulary rule, mechanically enforced)

The dependency direction can be clean while the vocabulary still leaks: a core
whose type names, identifiers, or comments name a provider depends on
concretions at the type level, and adding a second provider becomes a core edit
(OCP broken) instead of a new adapter. The rule:

- Provider names appear ONLY in: the provider's own module (adapter, transport
  DTOs, mapper, provider-specific actions — co-located with the port they
  serve), the composition root where adapters are wired, and port-id VALUES
  (`'github'` as a registry key is a value, not a type).
- Everywhere else — shared kernels, cross-cutting modules, neutral actions,
  comments — the vocabulary is provider-neutral: `remote`, `mirror`,
  `task manager`, `code host`. The provider quirk's knowledge stays in code in
  the provider module — a named method, a neutral field, or a test; never a
  comment.
- If shared code seems to need provider knowledge, the design is wrong: push
  the knowledge behind the port (a neutral field, a port method), or move the
  code into the provider module.

**Enforcement is mechanical, not aspirational:** a boundary gate (a grep script
or ESLint restriction, wired into the build) fails when a provider name appears
outside its allowed zones. Conventions without a gate erode one worker dispatch
at a time — prose in a brief is not a boundary. Reviewers and workers run the
gate; a violation is a blocking finding.

## Action objects (the use-case seam)

Each meaningful business operation is its own class — a **transaction script**
(Fowler) in command-pattern shape: single responsibility, immutable, one public
method (`call()` in Ruby, `__invoke()` in PHP — language-idiomatic), input as a
payload/DTO, dependencies via constructor injection (never resolved inside the
body). An action composes zero or more nested actions, each with its own single
responsibility.

**The story test decides what an action is.** Name it as a user story with its
own inputs and its own reason to exist: `CreateInvoiceAction` calls
`CreateInvoiceLineAction` in a loop, because a line is a small story. A
mechanical step with no independent meaning — "render the checklist", "detect a
rename" — is a function or a domain service the action calls, never a nested
action. Actions are small *because they are stories*, and small stories compose.

**The outermost action owns the transaction.** One story, one transaction: the
top-level action opens it (Laravel `DB::transaction`, Ruby
`ActiveRecord::Base.transaction`); a nested action never opens its own — it runs
inside the caller's.

```ruby
class CreatePostAction
  def initialize(audit_trail:)
    @audit_trail = audit_trail
  end

  def call(data)
    Post.transaction do
      post = Post.create(author_id: data.author_id, title: data.title)
      @audit_trail.call(post)
      post
    end
  end
end
```

Sizing and composition rules:

- Split actions small enough to reuse, large enough not to drown in them.
- Prefer copy-paste over premature abstraction; abstract by functionality,
  never by technical properties.
- Compose via constructor injection; avoid deep dependency chains.
- The primary payoff is cognitive load, not reusability: when a story changes,
  there is one meaningful place to go — the alternative is **shotgun surgery**
  (one story change, N files to touch).
- Rejected as overkill at this scale: command/handler buses, event-driven
  architectures.

### State via enums + guards

Rich enums guard their own transitions:

```ruby
class PostStatus
  DRAFT     = new
  PUBLISHED = new
  SCHEDULED = new

  def can_transition_to?(next_status)
    # ...
  end

  def transition_to(next_status)
    # ... raises DomainError on an invalid move
  end
end
```

The action wraps `transition_to` in a rescue, translating the `DomainError`
into a domain-specific exception — never imperative `raise unless` helpers.

## Domain building blocks (when each exists)

The model is a vocabulary with a bar per block, not a uniform checklist. Where
the textbook default diverges from ours, we say so.

- **Entity** — identity plus lifecycle; the default citizen of `domain/`. Bare
  name (`Post`, never `PostEntity`).
- **Value object** — enforces an invariant or carries behaviour, or prevents a
  real bug class; otherwise the primitive. Bare name.
- **Aggregate / aggregate root** — the consistency boundary: exactly what one
  transaction must keep consistent. As small as the invariants allow; one
  action, one transaction; other aggregates referenced by identity, never by
  object graph. Bare name (it is an entity).
- **Repository** — by default the action persists **directly** (Eloquent,
  ActiveRecord); a repository appears only when storage must be swappable or
  the domain tested without a DB (lean guardrail), never one per use case.
  Suffix `Repository`; *where* it sits is a project choice (an infrastructure
  adapter, or an application-layer repository behind a port).
- **Domain service** — pure logic spanning entities, owned by none, no I/O;
  *consulted by* a use case, never the reverse. Suffix `Service`, home
  `domain/`.
- **Application service** — orchestration shared across use cases; rare,
  because actions are the orchestration seam. Suffix `Service`, home
  `application/`.
- **Domain event** — something that happened in the domain; `Event`, `domain/`.
  One that crosses a component boundary is an integration event and lives in
  the shared kernel, so components share its shape without sharing the domain.
- **Read model / projection** — a query-shaped view; not until CQRS earns its
  keep. Reads go through queries and query builders.
- **Invariant / guard** — a rule that must always hold, owned by the entity,
  value object, or aggregate that has it and enforced at construction; the
  action wraps it and translates the error. Never a bare guard scattered
  through a use case.

**Value objects: extract on enforcement, not on shape.** A value object earns
its own class when it **enforces an invariant or carries behaviour** — a
`Money` that can't go negative, an `Email` that validates on construction — or
when it **prevents a real bug class** (wrapping IDs so a `UserId` can't be
passed where a `PostId` is expected). It does **not** earn its keep when it only
re-types a primitive: noise. Graça defaults to value objects over primitives;
we temper that with the lean guardrail: **enforce or prevent, otherwise keep the
primitive.**

**Data shapes: DTO, value, or private record — earn it, or it isn't a DTO.**
Before extracting a shape, it is exactly one of three: a **value object**
(domain, bare name); a **DataTransferObject** (application) — a *boundary
payload* that **crosses a module or port boundary**, is **named for the
concept, not the operation**, and is **reused or canonical**; or a **private
record** — the working memory of one algorithm, which is **not** a DTO: no
suffix, co-located with its consumer, never in `data/`. The default is the
fewest, most general shapes; near-duplicates collapse; a `*Data` that clears
none of these bars is the smell.

**We don't reach for** Specification, Unit of Work, Gateway, Decorator, or
Mediator classes by default; add one only when a concrete need can't be met by
an entity, a value object, a domain service, or an action.

**Architectural patterns (when they earn their keep):** event-driven for
decoupling/side effects/history, not simple synchronous flows; CQRS/CQS light
only (reads hit models/query builders directly, writes go through an action;
strict CQRS is overkill for CRUD); event sourcing only for audit-critical
domains; repository only when swapping storage or testing without a DB; no
service layer (actions are the use-case layer); saga/process manager only for
distributed transactions or multi-step rollback.

**SOLID, DRY, IoC as judgment:** SRP drives action objects (one class, one
reason to change); DRY is tempered by the Rule of Three; DI is always
constructor injection; Law of Demeter and composition over inheritance apply as
judgment.

## Modular monolith

One deployable, internally divided into **modules with explicit boundaries**. A
module is a hexagon; its `core` holds one or more components (bounded
contexts). Modules compose through the package graph — Composer path
repositories in the Laravel expression, engine gems in Rails (the mechanism
lives in the language skill); the shared kernel is itself a module.

- **Module** — a self-contained unit with a clear boundary; exposes a defined
  API, internals private. Its `core` holds the components (bounded contexts).
- **Owned data** — each module owns its data/schema and is its **single source
  of truth**; others don't reach in. A module may query data it doesn't own
  (read-only) but only changes data it owns.
- **Communication** — via contracts (events, actions), not direct coupling;
  peers never import each other, composition goes through the dependency graph.
- **Extractable** — the boundary makes a later service split possible.

## The working agreement (pushback)

The user wants a common conception of good software architecture — a ubiquitous
language for pair programming. In exchange, the agent is expected to **push
back on architecture when the context warrants it**, not just apply
conventions. When a convention would hurt in a given context, say so.

## The ARCHITECTURE.md contract

Every repository carries one `ARCHITECTURE.md` at the root — the merged
developer manual: where a new agent or developer finds their way around the
codebase and learns the conventions and best practices that shape it. It holds
the module map and boundaries, the flows as mermaid diagrams, the invariants,
and the enforced conventions. The stub is seeded by `project-seed` and filled
in by `architecture-and-skeleton` from the actual code; the same change that
alters the architecture updates it. Reviewers treat an architecture change
without the document update as blocking.
