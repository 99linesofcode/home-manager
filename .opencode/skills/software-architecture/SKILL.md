---
name: software-architecture
description: The user's software architecture contract — hexagonal-flavored layering for any Object Oriented language, driven by the lean guardrail (build lean, Rule of Three, concepts inform not dictate). Covers ports & adapters, canonical DTOs (the core owns its data shapes; one DTO per domain concept across providers), the UI/core/infrastructure split, action objects as the use-case seam (actions carry the logic), where logic lives (actions, domain services, pure calculations), modular monolith, and SOLID/IoC. Language-agnostic with pseudocode; the Laravel and Filament expressions are separate skills. Use when designing, building, extending, or reviewing the architecture of any OO codebase, when deciding how to structure a module, layer, or use case, or when defining the data shapes shared across adapters or providers.
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
to make classes findable by role.

**Long names are the convention, not a compromise.** A name's job is to
communicate intent and behavior; brevity is not a goal. Spell the whole thing
out — `CreateInvoiceDataTransferObject`, `SyncTasksFromProviderAction`,
`GithubTaskMapper`. Never abbreviate a role or a concept to save characters
(`DTO`, `Repo`, `Mgr`, `Svc`), and never drop the role suffix for length. The
IDE autocompletes; the reader pays for a cryptic name every time. Clarity wins
over brevity, always.

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

- **One class/interface per file.** The file name matches the symbol, per the
  language's convention — `create_task_note_action.rb` holds
  `CreateTaskNoteAction` in Ruby. An action's private input may share its file;
  anything consumed elsewhere gets its own.
- **The role is the suffix** — in the filename and the symbol name. The table
  is closed: every role has exactly one suffix; a name that carries none is
  either a carve-out (below) or wrong.

  | Role                    | Suffix         | Lives in |
  |-------------------------|----------------|----------|
  | Use case                | `Action`       | `application/actions/` |
  | Core-designed interface | `Port`         | `core/port/` |
  | Tool wrapper            | `Adapter`      | `infrastructure/<tool>/` |
  | Boundary payload (DTO)  | `DataTransferObject` | `application/` (port DTOs live with their port) |
  | Service (domain/app)    | `Service`      | `domain/` or `application/` |
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

  **Carve-outs** (no suffix, by design): domain **models** (`Post`, never
  `PostEntity`) — inside the domain layer the model is the default, so a suffix
  locates nothing; **enums** are descriptive (`PostStatus`, not
  `PostStatusEnum`); and **value objects** follow the enforcement rule (see
  "Value objects: extract on enforcement, not on shape"). Everything else
  carries its suffix — it is what makes a class findable by role and makes
  collisions impossible at scale (`CreatePost` alone could be a controller,
  command, job, or request).
- **Pure functions live in a file named after them** — no class wrapper, no
  suffix: `hash.rb`, `board_status.rb`, `folder_chain_for_path.rb` (Ruby). A
  module or a bare method, whichever the language favours. Class-internal
  helpers (step-down private methods serving one class) stay in that class's
  file.

### Folders: module-first, fractal

The top-level unit is the **module** — a hexagon, and **a repository is a
module** (in a monorepo, one package per module). Above it is composition;
inside it is its interior. This is our synthesis: Graça's dependency rule and
naming principle, with his axes inverted — the module outermost, the layers
inside. (Graça puts the layers outermost and the component inside; we put the
module outermost and the layers inside. Same rule, opposite nesting.) The
leading reference is Graça's `explicit-architecture-php` and
`explicit-architecture-reactjs`, paired with this module-first inversion.

```
<module root>/                   # the module IS the repo (or one package in a monorepo)
├── ui/                          # driving adapters (delivery)
│   └── <ui-type>/               # web / api / cli
├── core/                        # the module's core
│   ├── <component>/             # a component = a bounded context
│   │   ├── application/         # use cases (actions), queries, services, listeners
│   │   └── domain/              # entities, value objects, domain services, events
│   └── port/                    # ports shared across the module's components
└── infrastructure/              # driven adapters
    └── <tool>/<vendor>/
```

The entry point sits at the module root (`src/main.ts`), not inside a layer.
The shared kernel and language extensions are modules of their own (below), not
folders inside this one.

**The fractal — the shape repeats at every scale.** A module that wraps other
modules is a monorepo: each package is its own module (its own hexagon with the
same interior), composed through the **dependency graph** — Composer packages,
workspace packages — never nested folders. A hexagon is *never* placed inside
another hexagon's `core`: that would put UI code inside a core and break the
layer rule. Keep modules side by side and compose them through the graph.

**The base case — a component is `{application, domain}`.** A module is the
deployable (the repo); its `core` holds one or more **components** — the bounded
contexts. A module that is a single bounded context has exactly one component;
name it anyway (the component names the context, the repo names the module). A
component has no `ui` and no `infrastructure`: those exist only where something
is delivered or adapted, and a component is neither. The shape bottoms out
here. Never add empty `ui`/`infra` folders "for symmetry" — they imply a
delivery surface that isn't there.

**Promotion, not nesting.** When a component grows enough to be independently
deliverable, it *becomes* a module — promoted to a sibling hexagon (Rule of
Three). It does not grow `ui`/`infra` folders in place.

**Two other module kinds:**

- **Shared kernel** — a module with a degenerate interior: shared types only
  (events, IDs, value objects, enums, specs); no `ui`, no `infrastructure`, no
  use cases. The one module every other module may depend on.
- **Language extensions** — a module too, outside `src` in its own package:
  the language primitives we own (Graça's userland extensions).

**Dependency direction — two axes, not one:**

- **Lateral (peers).** Two peer bounded contexts must not know each other. The
  sanctioned channels are the shared kernel and events.
- **Vertical (composition).** A module may depend on the lower-level modules it
  wraps — how a library or language-extension module is used; the wrapping
  module is the composition point.

Dependencies form an acyclic graph pointing *downward* toward more fundamental
modules. What is forbidden is *lateral* coupling between peers. Inside a
module: `ui → core ← infrastructure`; nothing depends on `ui` or
`infrastructure`.

**The growth rule (when additional folders are warranted):** start flat and
group as the need arises — *"it is overzealous to create a folder to put
just one class in it"* (Graça). A role folder appears when a **second class
of that role** exists; the taxonomy is a menu, not an upfront scaffold.

**Language conventions win for naming and folder shape.** Folder structure
and file naming follow whatever is conventional for the language — PSR-4 in
PHP, snake_case files with PascalCase classes in Ruby — as long as the module
boundaries stay expressible; when this skill's structure and the language's convention
conflict, the language's convention wins. The discipline that transfers
across languages: the path locates the module, the name locates the role,
the entry point sits at the conventional root, and the module dependency
matrix is enforced mechanically (a boundary gate) — a naming standard
without a gate erodes one dispatch at a time. Language-specific expressions
live in the language's skeleton or expression skill, never here.
When one business concept comes to dominate a role folder, split by concept
*inside* the role folder — or, if the concept has outgrown the module, that
is the signal to extract it into its own module. At the leaf, grouping by
subject or by role both work; the choice is cheap to change later. Every
split serves one target: **high cohesion** within a folder, **low coupling**
across them.

**The role menu** (closed; extend only by decision, never per repo):

| Area                            | Roles |
|---------------------------------|-------|
| `core/<component>/application/` | `actions/` (`Action`), `data/` (`DataTransferObject`), `queries/` (`Query`), `services/` (`Service`), `listeners/` (`Listener`), repository interfaces |
| `core/<component>/domain/`      | `models/` (bare), `enums/` (descriptive: `PostStatus`), `events/` (`Event`), `errors/` (`Error`), `rules/` (`Rule`), domain services (`Service`) |
| `core/port/`                    | `Port` interfaces, plus the value objects, DTOs, builders and query objects they need |
| `ui/`                           | `controllers/`, `commands/`, `requests/`, `resources/`, `view-models/`, `scheduling/` |
| `infrastructure/<tool>/`        | `Adapter` — one subfolder per tool; a second vendor adapter earns a per-vendor subfolder |

A **port is rarely just an interface**: it may carry the value objects,
DTOs, builders, and query objects the core needs to use the tool — all of
that lives with the port.

**Co-location: role folders for shared, consumer folders for exclusive.** A
role folder (`actions/`, `queries/`) tells you what *kinds* exist; it never
tells you what wraps what. Flow legibility comes from **consumer-scoped
placement** (Graça): every consumer — a controller, a use case, a CLI command —
owns a folder, and everything used *exclusively by it* lives inside that
folder. An action with exclusive collaborators (nested actions, a private
query, a private payload) becomes a folder named after it; a leaf action stays
a single file. Shared collaborators stay at the role level, because several
consumers use them.

```
core/<component>/application/
├── actions/
│   ├── publish_post_action.rb          # leaf — no exclusive collaborators
│   └── sync_tasks/                     # consumer folder
│       ├── sync_tasks_action.rb        # the entry point of the flow
│       ├── merge_task_action.rb        # nested, exclusive to this flow
│       └── task_conflict_data_transfer_object.rb  # exclusive payload
└── queries/
    └── list_projects_query.rb          # shared — several consumers use it
```

Co-location applies **within each layer**: an action's exclusive collaborators
live in its folder under `application/`; a domain concept's exclusive types
live in its folder under `domain/`.

The test is *actual usage*, not topic: exclusive → inside the consumer's
folder; shared → at the role level. Moving a class between the two is a
placement change, never a behavior change. This is what makes the tree answer
"what wraps what" without opening imports — the nesting *is* the composition.

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

## Domain building blocks (when each exists)

The model is a vocabulary with a bar per block, not a uniform checklist. Where
the textbook default diverges from ours, we say so.

- **Entity** — identity plus lifecycle; the default citizen of `domain/`. Bare
  name (`Post`, never `PostEntity`).
- **Value object** — enforces an invariant or carries behaviour, or prevents a
  real bug class; otherwise the primitive. Bare name. Bar below.
- **Aggregate / aggregate root** — the consistency boundary: exactly what one
  transaction must keep consistent. As small as the invariants allow; one action,
  one transaction; other aggregates referenced by identity, never by object
  graph. Bare name (it is an entity).
- **Repository** — only when storage must be swappable or the domain tested
  without a DB (lean guardrail); never one per use case. Suffix `Repository`; in
  the Laravel expression, none over Eloquent.
- **Domain service** — pure logic spanning entities, owned by none, no I/O;
  *consulted by* a use case, never the reverse. Suffix `Service`, home `domain/`.
- **Application service** — orchestration shared across use cases; rare, because
  actions are the orchestration seam. Suffix `Service`, home `application/`.
- **Domain event** — something that happened in the domain; `Event`, `domain/`.
  One that crosses a component boundary is an integration event and lives in the
  shared kernel, so components share its shape without sharing the domain.
- **Read model / projection** — a query-shaped view; not until CQRS earns its
  keep. Reads go through queries and query builders.
- **Invariant / guard** — a rule that must always hold, owned by the entity,
  value object, or aggregate that has it and enforced at construction; the action
  wraps it and translates the error. Never a bare guard scattered through a use
  case.

**Value objects: extract on enforcement, not on shape.** A value object earns
its own class when it **enforces an invariant or carries behaviour** — a `Money`
that can't go negative, an `Email` that validates on construction, a `Slug` that
can't be empty — or when it **prevents a real bug class** (wrapping IDs so a
`UserId` can't be passed where a `PostId` is expected). It does **not** earn its
keep when it only re-types a primitive: noise — more files, no new guarantee.
Graça defaults to value objects over primitives; we temper that with the lean
guardrail: **enforce or prevent, otherwise keep the primitive.**

**Data shapes: DTO, value, or private record — earn it, or it isn't a DTO.**
Before extracting a shape, it is exactly one of three: a **value object**
(domain, bare name); a **DataTransferObject** (application) — a *boundary
payload* that **crosses a module or port boundary**, is **named for the concept,
not the operation**, and is **reused or canonical**, home `application/data/`; or
a **private record** — the working memory of one algorithm, which is **not** a
DTO: no suffix, co-located with its consumer, never in `data/`. The default is
the fewest, most general shapes; near-duplicates collapse; a `*Data` that clears
none of these bars is the smell.

**We don't reach for** Specification, Unit of Work, Gateway, Decorator, or
Mediator classes by default; add one only when a concrete need can't be met by an
entity, a value object, a domain service, or an action.

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
  UI mechanics), `software-testing` (how the layers are tested).
- **Leading reference:** Graça's reference implementations —
  `hgraca/explicit-architecture-php` and `hgraca/explicit-architecture-reactjs`
  — paired with our module-first convention. Where this skill and the reference
  apps differ, this skill wins (we invert Graça's axes); where this skill is
  silent, mirror the reference apps.
- Wiki concepts: `architecturally-evident-structure.md` (Graça's taxonomy, which
  this skill distills and inverts), `ddd.md`, `hexagonal-architecture.md`,
  `action-objects.md`, `modular-monolith.md`,
  `software-architecture-principles.md`.
