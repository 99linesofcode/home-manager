---
name: software-architecture
description: The user's software architecture contract — hexagonal-flavored layering for any Object Oriented language, driven by the lean guardrail (build lean, Rule of Three, concepts inform not dictate). Covers ports & adapters, canonical DTOs (the core owns its data shapes; one DTO per domain concept across providers), the UI/core/infrastructure split, action objects as the use-case seam (actions carry the logic), where logic lives (actions, domain services, pure calculations), modular monolith, and SOLID/IoC. Language-agnostic with pseudocode; the language expressions are separate skills (`laravel`/`filament`, `rails`/`avo`). Use when designing, building, extending, or reviewing the architecture of any OO codebase, when deciding how to structure a module, layer, or use case, or when defining the data shapes shared across adapters or providers.
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
2. **Convention over configuration.** Prefer a uniform, predictable structure
   and sensible defaults over per-instance knobs; follow the language's
   standards and the ecosystem's established tools, and minimize custom rules.
   A convention everyone follows beats a configuration everyone must set.
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

## Convention over configuration (the default stance)

Prefer a convention everyone follows over a configuration everyone sets. This
is the operating default for the whole setup, not just code:

- **Uniform anatomy.** Every artefact of a kind looks the same — skills,
  agents, specs, project homes, module skeletons. Predictable structure is
  cheaper than flexible structure: a reader (human or agent) finds what they
  expect without being told.
- **Sensible defaults first.** Ship a working default — agent, model,
  permissions, project layout, devshell — and let a project override it only
  where it genuinely differs. A per-project override is the exception, not the
  setup step.
- **Convention beats a knob.** A knob is a decision deferred to every caller;
  if a convention can absorb the case, don't expose the knob. Add one only when
  a real, recurring need can't be met by the convention — the same test as the
  lean guardrail below.
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
   before.
3. **Does it make verification cheaper, or add ceremony?** A layer earns its
   keep by making the behavior easier to verify — a seam to inject a fake, a
   boundary to test against — not by mirroring a diagram. For an agent, every
   layer between the caller and the behavior is another file to read: a tool
   call and a context tax. A layer that buys neither verifiability nor real
   isolation is ceremony — skip it.
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
| Raw external data ↔ domain | **Adapters, at the boundary** | an anti-corruption layer: map raw responses onto the domain's canonical DTOs; the core never sees provider shapes — including DTOs that mimic a provider's structure (see "DTOs belong to the core") |
| State-specific behavior | **Rich enums / state pattern** | when states multiply; not before |
| Queries | **Query builders / read models** | models stay dumb data + identity |

Anti-patterns: a **god object** (an "Engine"/"Manager" accumulating
decisions); a "Service" layer duplicating what actions already do; business
logic in jobs/listeners (infrastructure *around* actions, never logic
holders); logic smeared across controller + model + job + listener.

## File organization & naming (the contract in brief)

Every artefact name carries two axes: its **domain concept** (which module it
belongs to) and its **role** (which folder it lives in, what it may depend on,
how it is invoked, its suffix) — `InvoiceRepository`: `Invoice` domain, `Repository` role.

```
<module root>/                   # the module IS the repo (or one package in a monorepo)
├── ui/                          # driving adapters (delivery)
│   └── <ui-type>/               # web / api / cli
├── core/                        # the module's core
│   ├── application/             # use cases (actions), queries, services, listeners
│   ├── domain/                  # entities, value objects, domain services, events
│   └── port/                    # the ports the core owns
└── infrastructure/              # driven adapters
    └── <tool>/<vendor>/
```

**The role is the suffix** (in the filename and the symbol name). The table is
closed: every role has exactly one suffix; a name that carries none is either a
carve-out or wrong.

| Role                    | Suffix         | Lives in |
|-------------------------|----------------|----------|
| Use case                | `Action`       | `application/actions/` |
| Core-designed interface | `Port`         | `core/port/` |
| Tool wrapper            | `Adapter`      | `infrastructure/<tool>/` |
| Boundary payload (DTO)  | `DataTransferObject` | `application/` (port DTOs live with their port) |
| Service (domain/app)    | `Service`      | `domain/` or `application/` |
| Reconciler (sync chain) | `Reconciler`   | `core/application/services/` |
| Query                   | `Query`        | `application/queries/` |
| Domain event            | `Event`        | `domain/` or the shared kernel |
| Event listener          | `Listener`     | `application/listeners/` |
| Mapper                  | `Mapper`       | beside its consumer |
| Parser                  | `Parser`       | beside its consumer |
| Rule                    | `Rule`         | `domain/rules/` |
| State                   | `State`        | `domain/states/` |
| Query builder           | `QueryBuilder` | `domain/` |
| Collection              | `Collection`   | `domain/` |
| Factory                 | `Factory`      | `domain/` |
| Error                   | `Error`        | `domain/errors/` |
| Controller              | `Controller`   | `ui/` |
| Command                 | `Command`      | `ui/` |
| Request                 | `Request`      | `ui/` |
| Resource                | `Resource`     | `ui/` |
| View model              | `ViewModel`    | `ui/` |
| Scheduler               | `Scheduler`    | `ui/` |

**The role menu** (closed; extend only by decision, never per repo):

| Area                            | Roles |
|---------------------------------|-------|
| `core/application/`             | `actions/` (`Action`), `data/` (`DataTransferObject`), `queries/` (`Query`), `services/` (`Service`), `listeners/` (`Listener`), repository interfaces |
| `core/domain/`                  | `models/` (bare), `enums/` (descriptive: `PostStatus`), `events/` (`Event`), `errors/` (`Error`), `rules/` (`Rule`), domain services (`Service`) |
| `core/port/`                    | `Port` interfaces, plus the value objects, DTOs, builders and query objects they need |
| `ui/`                           | `controllers/`, `commands/`, `requests/`, `resources/`, `view-models/`, `scheduling/` |
| `infrastructure/<tool>/`        | `Adapter` — one subfolder per tool; a second vendor adapter earns a per-vendor subfolder |

The rationale, the fractal, co-location, Support and the boundary rules are in `references/file-organization.md`.

## Domain building blocks & patterns

The building blocks (entity, value object, aggregate, repository, domain and
application services, events, read models, invariants), the architectural
patterns that earn their keep, and how SOLID/DRY/IoC apply as judgment are in
`references/domain-building-blocks.md`.

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

**DTOs belong to the core, not the provider.** A port's DTOs are designed
for the core's needs exactly as the port itself is — never mimicking a
tool's API. "The core never sees provider shapes" includes shapes wearing
a DTO costume: a `TaskDataTransferObject` whose fields mirror the GitHub issue is a
provider shape. **One canonical DTO per domain concept:** when a second
adapter serves the same concept (a second provider, a second storage, a
second UI), both map onto the SAME domain DTO — parallel per-provider DTO
vocabularies are the anti-corruption layer failing silently. The second
provider is the Rule-of-Three trigger to unify the shapes.

**The canonical test:** when two representations of the same concept must
be compared, merged, or synced, the diff logic operates on canonical
fields only. If it references provider-specific fields, the canonical
model is missing. Accumulating symptoms: per-pair diff/verdict machinery,
duplicated hash/translation helpers, provider-shaped snapshot fragments.
Worked example (OPM, 2026-09-25): GitHub and Todoist each got their own
task DTO vocabulary — five snapshot-hash copies, two verdict systems,
and a done/open coercion bug followed; the canonical `TaskDataTransferObject` with one
mapper per side dissolved all of them.

Dependencies point **inward** — the **dependency rule**: the domain layer
knows nothing about the application layer; the core knows nothing about
adapters.

Folder shape — module-first (see "Folders: module-first, fractal"):

```
<module root>/
├── ui/                 # driving adapters (controllers, commands, schedulers)
├── core/               # components ({application, domain}) + port/
└── infrastructure/     # driven adapters (empty until there's a real need)
```

Enforce with a dependency-graph tool (e.g. Deptrac in PHP) in CI: allowed
dependencies between layers, build fails on violation. This is what keeps
the structure from **architectural drift** — the structure decays one
import at a time unless a gate rejects it.

### Provider neutrality (the vocabulary rule, mechanically enforced)

The dependency direction can be clean while the vocabulary still leaks: a
core whose type names, identifiers, or comments say "GitHub" or "Todoist"
depends on concretions at the type level, and adding a second provider
becomes a core edit (OCP broken) instead of a new adapter. The rule:

- Provider names appear ONLY in: the provider's own module (adapter,
  transport DTOs, mapper, provider-specific actions — co-located with the
  port they serve), the composition root where adapters are wired, and
  port-id VALUES (`'github'` as a registry key is a value, not a type).
- Everywhere else — shared kernels, cross-cutting modules, neutral actions,
  comments — the vocabulary is provider-neutral: `remote`, `mirror`,
  `task manager`, `code host`. A WHY comment explaining a provider quirk
  belongs in the provider module that handles it.
- If shared code seems to need provider knowledge, the design is wrong:
  push the knowledge behind the port (a neutral field, a port method), or
  move the code into the provider module.

**Enforcement is mechanical, not aspirational:** a boundary gate (a grep
script or ESLint restriction, wired into the build) fails when a provider
name appears outside its allowed zones. Conventions without a gate erode one
worker dispatch at a time — prose in a brief is not a boundary. Reviewers
and workers run the gate; a violation is a blocking finding. Worked example
(OPM, 2026-10-06): the layering audit passed — dependency direction was
clean — while `GithubTaskData`/`TodoistTaskData` sat in the shared kernel and
core comments explained GitHub quirks. Clean direction, concreted vocabulary;
the gate is what would have caught it on day one.

## Action objects (the use-case seam)

Each meaningful business operation is its own class — a **transaction
script** (Fowler) in command-pattern shape: single responsibility,
immutable, one public method (`call()` in Ruby, `__invoke()` in PHP —
language-idiomatic), input as a payload/DTO, dependencies via constructor
injection (never resolved inside the body). An action composes zero or more
nested actions, each with its own single responsibility.

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

The action wraps `transition_to` in a rescue, translating the
`DomainError` into a domain-specific exception — never imperative
`raise unless` helpers.

## Modular monolith

One deployable, internally divided into **modules with explicit boundaries**.
A module is a hexagon (see "Folders: module-first, fractal"); its `core` holds
one or more components (bounded contexts). In the Laravel expression, modules
are Composer packages and the shared kernel is itself a module
(`laravel-module-support`).

- **Module** — a self-contained unit with a clear boundary; exposes a defined
  API, internals private. Its `core` holds the components (bounded contexts).
- **Owned data** — each module owns its data/schema and is its **single
  source of truth**; others don't reach in. A module may query data it
  doesn't own (read-only) but only changes data it owns.
- **Communication** — via contracts (events, actions), not direct coupling;
  peers never import each other, composition goes through the dependency graph.
- **Extractable** — the boundary makes a later service split possible.

## The working agreement (pushback)

The user wants a common conception of good software architecture — a
ubiquitous language for pair programming. In exchange, the agent is expected
to **push back on architecture when the context warrants it**, not just apply
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

## Related

- **Loads:** (none — this is a leaf contract)
- **References:** `laravel` (the Laravel mechanics), `filament` (the Filament
  UI mechanics), `rails` (the Rails mechanics), `avo` (the Avo UI mechanics),
  `software-testing` (how the layers are tested).
- **Reference files:** `references/file-organization.md` (folder shape, role
  suffixes, co-location, Support, boundary rules),
  `references/domain-building-blocks.md` (domain building blocks, architectural
  patterns, SOLID/DRY/IoC).
- **Leading reference:** Graça's reference implementations —
  `hgraca/explicit-architecture-php` and `hgraca/explicit-architecture-reactjs`
  — paired with our module-first convention. Where this skill and the reference
  apps differ, this skill wins (we invert Graça's axes); where this skill is
  silent, mirror the reference apps.
- Wiki concepts: `architecturally-evident-structure.md` (Graça's taxonomy, which
  this skill distills and inverts), `ddd.md`, `hexagonal-architecture.md`,
  `action-objects.md`, `modular-monolith.md`,
  `software-architecture-principles.md`.
