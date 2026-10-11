---
name: software-architecture-structure
description: The structure-and-naming half of the architecture contract — the folder tree, the closed role-suffix table, one class per file, and the boundary rules. It exists so every file has one obvious name and place. Use when creating, moving, naming, or placing a class or file, choosing a folder, adding a module, or reviewing a repository's structure.
metadata:
  category: architecture
  route-when: "Use when creating, moving, naming, or placing a class or file, choosing a folder, picking a role suffix, adding a module, or reviewing a repository's structure."
  route-not-when: "Use `software-architecture` for the principles, where logic lives, the hexagonal rules, DTOs, or provider neutrality."
---

# software-architecture-structure

The **structure and naming** half of the architecture contract: the folder
tree, the closed role-suffix table, one class per file, co-location, and the
boundary rules. The other half — principles, where logic lives, the hexagonal
rules, DTOs, provider neutrality — is `software-architecture`.

Grounded in Graça's architecturally evident structure
(`wiki/concepts/architecturally-evident-structure.md`) and the Stitcher *Laravel
Beyond CRUD* study. The reference implementations are the **laravel-module-\***
packages; mirror them when a rule is silent.

## Related

- **Loads:** (none — the core Loads this skill; this skill References it).
- **References:** `software-architecture`, `laravel`, `rails`, `typescript`,
  `premise-demolition`, `systems-thinking`.

## External

| Path | Load | Read when |
|---|---|---|
| `~/Development/laravel-module-*` | on-demand | the reference module family — mirror it where this skill is silent |
| `https://github.com/hgraca/explicit-architecture-php` | on-demand | Graça's reference implementation, which we invert |
| `~/Documents/Obsidian/AI/wiki/concepts/architecturally-evident-structure.md` | on-demand | for the rationale behind the taxonomy |

## When to use

- Creating or moving a class or file, or choosing the folder it belongs in.
- Naming a file or class, or picking its role suffix.
- Adding a module, or reviewing a repo's structure.

<!-- card:start -->
## Always-on card (software architecture)

**The module tree** — a module is the repo (or one package); its interior:

```
<module root>/
├── ui/              # driving adapters: controllers, commands, schedulers
├── core/
│   ├── application/ # actions, data (DTOs), queries, services, listeners
│   ├── domain/      # models, enums, events, errors, rules, services
│   └── port/        # the interfaces the core owns
└── infrastructure/  # driven adapters: one folder per tool, then vendor
```

A single-context module has no component wrapper — `application/`, `domain/`,
`port/` sit directly under `core/`.

**Roles are suffixes (closed table).** `Action`, `Port`, `Adapter`,
`DataTransferObject`, `Service`, `Query`, `Event`, `Listener`, `Mapper`,
`Parser`, `Rule`, `State`, `QueryBuilder`, `Collection`, `Factory`, `Error`,
`Controller`, `Command`, `Request`, `Resource`, `ViewModel`, `Scheduler`.
Carve-outs with no suffix: domain models (`Post`), descriptive enums
(`PostStatus`). A project needing an extra role adds it in its own repo-local
skill.

**Three hard rules:**
1. Dependencies point inward — `ui → core ← infrastructure`; nothing depends
   on `ui` or `infrastructure`.
2. No provider shapes in the core — canonical DTOs only; provider names only in
   the provider module.
3. One class per file; the file name matches the symbol.
<!-- card:end -->

## The two axes of a name

Every artefact name carries two meanings, and both must be evident:

- **Domain concept** — the bounded-context concept it serves (`Invoice`,
  `Task`, `Board`). Decides *which module* it belongs to.
- **Role** — the architectural stereotype it instantiates (use case, port,
  adapter, payload, error, mapper, …). Decides *which folder it lives in*,
  *what it may depend on*, *how it is invoked*, and *its suffix*.

`InvoiceRepository`: `Invoice` is the domain, `Repository` is the role. The
role suffix exists to make name collisions impossible at scale
(`CreateInvoice` alone could be a controller, command, job, or request) and to
make classes findable by role.

**Long names are the convention, not a compromise.** A name's job is to
communicate intent and behavior; brevity is not a goal. Spell the whole thing
out — `CreateInvoiceDataTransferObject`, `SyncTasksFromProviderAction`. Never
abbreviate a role or a concept to save characters (`DTO`, `Repo`, `Mgr`,
`Svc`), and never drop the role suffix for length. Clarity wins over brevity,
always.

**The carve-out:** not every artefact gets a suffix. Domain-model classes are
the model itself — `Post`, never `PostEntity`: inside the domain layer "entity"
is the default, so the suffix locates nothing and is noise. A suffix earns its
place when the role is *not* the default for its layer.

## What a "technical role" is

A **role** (Graça's term; formally an *architectural stereotype*) is the kind
of responsibility an artefact carries in the architecture — what it *is*,
independent of the domain concept it serves. The role vocabulary comes from the
tactical patterns: DDD's building blocks (Entity, Value Object, Repository,
Factory, Service, Domain Event), hexagonal's Port/Adapter/use case, and pattern
participant roles (Mapper, Parser, Scheduler).

**The test:** a word is a role when it *locates the class* — it answers which
folder the class lives in, what it may depend on, and how it is invoked. If a
word changes none of those answers, it is not a role: `Entity` is noise;
`Manager`/`Helper`/`Util` are metaphors that name no responsibility. Both are
banned.

## One class per file

- **One class/interface per file.** The file name matches the symbol, per the
  language's convention — `create_task_note_action.rb` holds
  `CreateTaskNoteAction` in Ruby. An action's private input may share its file;
  anything consumed elsewhere gets its own.
- **The role is the suffix** — in the filename and the symbol name. The table
  is closed: every role has exactly one suffix; a name that carries none is
  either a carve-out or wrong.

| Role | Suffix | Lives in |
|---|---|---|
| Use case | `Action` | `application/actions/` |
| Core-designed interface | `Port` | `core/port/` |
| Tool wrapper | `Adapter` | `infrastructure/<tool>/` |
| Boundary payload (DTO) | `DataTransferObject` | `application/` (port DTOs live with their port) |
| Service (domain/app) | `Service` | `domain/` or `application/` |
| Query | `Query` | `application/queries/` |
| Domain event | `Event` | `domain/` or the shared kernel |
| Event listener | `Listener` | `application/listeners/` |
| Mapper | `Mapper` | beside its consumer |
| Parser | `Parser` | beside its consumer |
| Rule | `Rule` | `domain/rules/` |
| State | `State` | `domain/states/` |
| Query builder | `QueryBuilder` | `domain/` |
| Collection | `Collection` | `domain/` |
| Factory | `Factory` | `domain/` |
| Error | `Error` | `domain/errors/` |
| Controller | `Controller` | `ui/` |
| Command | `Command` | `ui/` |
| Request | `Request` | `ui/` |
| Resource | `Resource` | `ui/` |
| View model | `ViewModel` | `ui/` |
| Scheduler | `Scheduler` | `ui/` |

**Carve-outs** (no suffix, by design): domain **models** (`Post`, never
`PostEntity`); **enums** are descriptive (`PostStatus`, not `PostStatusEnum`);
and **value objects** follow the enforcement rule (see `software-architecture`).
Everything else carries its suffix.

**Interfaces carry their role suffix, never a construct marker.** No `I` prefix
(`IPostRepository`) and no `Interface` suffix (`PostRepositoryInterface`) — both
name the language construct, which is not a role. A port is `XPort`; a boundary
shape is named for its role (`CodeHostResponse`). Graça's
explicit-architecture uses the `Interface` suffix; we do not. The TypeScript
expression lives in the `typescript` skill.

- **Pure functions are grouped into a cohesive unit, not one file each.** A
  file per trivial helper clutters the tree and costs a read for no meaning.
  Group related pure functions by subject, and pick the form by the DDD test: a
  **value object** where the behaviour belongs to a concept and enforces an
  invariant (`ProjectName`, `VaultPath`); a **domain service** only where the
  operation spans several objects and belongs to none (`MergeService`); a plain
  **module file** where the transforms own nothing (`note.rb`, `support.rb`).
  The default is the model object — a service is the exception, never a home
  for cohesion. Class-internal helpers stay in that class's file.

## The role menu (closed)

Extend only by decision, never per repo:

| Area | Roles |
|---|---|
| `core/application/` | `actions/` (`Action`), `data/` (`DataTransferObject`), `queries/` (`Query`), `services/` (`Service`), `listeners/` (`Listener`), repository interfaces |
| `core/domain/` | `models/` (bare), `enums/` (descriptive: `PostStatus`), `events/` (`Event`), `errors/` (`Error`), `rules/` (`Rule`), domain services (`Service`) |
| `core/port/` | `Port` interfaces, plus the value objects, DTOs, builders and query objects they need |
| `ui/` | `controllers/`, `commands/`, `requests/`, `resources/`, `view-models/`, `scheduling/` |
| `infrastructure/<tool>/` | `Adapter` — one subfolder per tool; a second vendor adapter earns a per-vendor subfolder |

In a module that wraps several bounded contexts, the `core/application/` and
`core/domain/` rows nest one level deeper, under `core/<component>/`.

**A project that needs a role the table lacks adds it in that project's own
repo-local skill** (`.opencode/skills/`), with its suffix and folder; the table
here stays closed. A role that turns out to be user-wide earns a row here by
decision.

## Folders: module-first, fractal

The top-level unit is the **module** — a hexagon, and **a repository is a
module** (in a monorepo, one package per module). Above it is composition;
inside it is its interior. This is our synthesis: Graça's dependency rule and
naming principle, with his axes inverted — the module outermost, the layers
inside.

```
<module root>/                   # the module IS the repo (or one package)
├── ui/                          # driving adapters (delivery)
│   └── <ui-type>/               # web / api / cli
├── core/                        # the module's core
│   ├── application/             # use cases (actions), queries, services, listeners
│   ├── domain/                  # entities, value objects, domain services, events
│   └── port/                    # the ports the core owns
└── infrastructure/              # driven adapters
    └── <tool>/<vendor>/
```

The entry point sits at the module root (`src/main.ts`), not inside a layer.
The shared kernel and language extensions are modules of their own, not folders
inside this one.

**The fractal — the shape repeats at every scale.** A module that wraps other
modules is a monorepo: each package is its own module (its own hexagon with the
same interior), composed through the **dependency graph** — Composer packages,
workspace packages — never nested folders. A hexagon is *never* placed inside
another hexagon's `core`: that would put UI code inside a core and break the
layer rule. Keep modules side by side and compose them through the graph.

**The base case — a single-context module is `{application, domain}` under
`core`.** A module is the deployable (the repo); its `core` holds the bounded
contexts. A module that is a **single** bounded context has no component
wrapper: `application/`, `domain/` and `port/` sit directly under `core/`.
Naming a component after the module's own subject is the anti-pattern — the
subject names the module, not a component (`Shop` is not a component of the
shop app). A module that wraps **several** contexts groups them under
`core/<component>/`, each with its own `application/` + `domain/`. A component
has no `ui` and no `infrastructure`: those exist only where something is
delivered or adapted. Never add empty `ui`/`infra` folders "for symmetry" —
they imply a delivery surface that isn't there.

**Promotion, not nesting.** When a component grows enough to be independently
deliverable, it *becomes* a module — promoted to a sibling hexagon (Rule of
Three). It does not grow `ui`/`infra` folders in place.

**Two other module kinds:**

- **Shared kernel** — a module with a degenerate interior: shared types only
  (events, IDs, value objects, enums, specs); no `ui`, no `infrastructure`, no
  use cases. The one module every other module may depend on.
- **Language extensions** — a module too, outside `src` in its own package: the
  language primitives we own.

**Dependency direction — two axes, not one:**

- **Lateral (peers).** Two peer bounded contexts must not know each other. The
  sanctioned channels are the shared kernel and events.
- **Vertical (composition).** A module may depend on the lower-level modules it
  wraps; the wrapping module is the composition point.

Dependencies form an acyclic graph pointing *downward* toward more fundamental
modules. What is forbidden is *lateral* coupling between peers. Inside a
module: `ui → core ← infrastructure`; nothing depends on `ui` or
`infrastructure`.

**The growth rule (when additional folders are warranted):** start flat and
group as the need arises — *"it is overzealous to create a folder to put just
one class in it"* (Graça). A role folder appears when a **second class of that
role** exists; the taxonomy is a menu, not an upfront scaffold.

**Language conventions win for naming and folder shape.** Folder structure and
file naming follow whatever is conventional for the language — PSR-4 in PHP,
snake_case files with PascalCase classes in Ruby — as long as the module
boundaries stay expressible; when this skill's structure and the language's
convention conflict, the language's convention wins. The discipline that
transfers across languages: the path locates the module, the name locates the
role, the entry point sits at the conventional root, and the module dependency
matrix is enforced mechanically (a boundary gate) — a naming standard without a
gate erodes one dispatch at a time. Language-specific expressions live in the
language's skeleton or expression skill, never here.

When one business concept comes to dominate a role folder, split by concept
*inside* the role folder — or, if the concept has outgrown the module, that is
the signal to extract it into its own module. At the leaf, grouping by subject
or by role both work; the choice is cheap to change later. Every split serves
one target: **high cohesion** within a folder, **low coupling** across them.

## The tree in full — each level groups by its own axis

The organising axis changes as you descend; that is what decides what belongs
where. From the top:

- `ui/` — by **UI type** (api, cli, web), then the specific UI, then the
  component.
- `core/` — by **component** (bounded context). `port/` and the shared kernel
  sit *beside* the components, never inside one.
- `core/<component>/` — the two layers: `application/`, `domain/`.
- `core/<component>/application/` and `/domain/` — by **subject or role**, your
  choice at the leaf. Start flat and group as it hurts; the choice is cheap
  because it is the leaf.
- `core/port/` — by the **tool type** the core uses (auth, messaging, …).
- `infrastructure/` — by **tool type**, then by vendor adapter.

Canonical shape (Graça) — note he groups `Application/` by role and `Domain/`
by subject in the same demo, the "either axis at the leaf" rule in practice:

```
src/
├── UserInterface/{API, Console, Website}/<component>/
├── Core/
│   ├── Component/Blog/{Application, Domain}/  # Application by role, Domain by subject
│   ├── Port/{Auth, EventDispatcher}/
│   └── SharedKernel/
└── Infrastructure/  <tool>/<vendor>/
lib/lang-extension/{src,tests}/
```

Our module-first adaptation — same axes, inverted nesting, no wrapper for a
single context:

```
<module root>/                        # the repo IS the module
├── ui/<ui-type>/<component>/
├── core/
│   ├── <component>/                  # omitted for a single-context module
│   │   ├── application/
│   │   └── domain/
│   └── port/                         # beside the components, never inside one
└── infrastructure/<tool>/<vendor>/
```

Where the two differ — and this skill wins:

- **The nesting is inverted.** Graça puts the layers outermost and the
  component inside `Core`; we put the module (the repo) outermost and the
  layers inside.
- **No component wrapper for a single-context module** (ADR 004).
- **Names carry the role** — enforced by a gate.

## Co-location: role folders for shared, consumer folders for exclusive

A role folder (`actions/`, `queries/`) tells you what *kinds* exist; it never
tells you what wraps what. Flow legibility comes from **consumer-scoped
placement** (Graça): every consumer — a controller, a use case, a CLI command —
owns a folder, and everything used *exclusively by it* lives inside that
folder. An action with exclusive collaborators (nested actions, a private
query, a private payload) becomes a folder named after it; a leaf action stays
a single file. Shared collaborators stay at the role level.

```
core/application/
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
live in its folder under `application/`; a domain concept's exclusive types live
in its folder under `domain/`.

The test is *actual usage*, not topic: exclusive → inside the consumer's
folder; shared → at the role level. Moving a class between the two is a
placement change, never a behavior change. This is what makes the tree answer
"what wraps what" without opening imports — the nesting *is* the composition.

## Support, not Utils

A `Support/` folder is legitimate for **generic, universal concepts** — code
that could have been part of the framework or language (Graça's userland
extensions; Brent's `Support\` namespace). Everything admitted must be
conceptually cohesive, and Support is a staging area: when a cluster matures,
extract it into its own component/package. What is banned is the grab-bag — a
`Utils/`/`Commons/` folder where misfit code is dumped with no conceptual
meaning; that is the first step toward a **big ball of mud**. When unsure where
code goes, the answer is one of: its proper role folder (domain-specific),
`Support/` (generic and cohesive), the shared kernel (already extracted), or it
doesn't exist yet.

## Boundary rules

- **The application's subject is not a component.** If the whole app is a shop,
  `Shop` is not a module — its parts (`Owner`, `Products`) are.
- **Applications don't talk to each other.** Each driving surface (HTTP, CLI,
  API) consumes the domain; they never call each other.
- **Handler vs listener placement:** a command handler lives next to the one
  command that triggers it; an event listener never lives next to the event
  (events have several triggers and several listeners).
- **Repository sizing:** one repository per entity per data source
  (occasionally per aggregate); never one gateway per database; never per use
  case. Placement is a project choice: repository-as-adapter (implementation in
  Infrastructure) or repositories in the application layer behind a persistence
  port.
- **Structure iterates.** Domains are carved, then refactored — a domain that
  outgrows grasp splits. Domain code has few dependencies, so moving is cheap;
  don't fear starting, fear not refactoring.
- **Ports carry their rationale**: a short comment stating the core's need —
  designed for the core, never mimicking the tool's API.
- **A repo that is itself a single adapter** (a thin skin over one external
  tool, no business logic) does not get the three-folder shape — that would be
  ceremony. Flat structure, classes + role suffixes, pure function-files.
