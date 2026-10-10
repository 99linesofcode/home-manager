# File organization & naming

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
│   ├── application/             # use cases (actions), queries, services, listeners
│   ├── domain/                  # entities, value objects, domain services, events
│   └── port/                    # the ports the core owns
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

**The base case — a single-context module is `{application, domain}` under
`core`.** A module is the deployable (the repo); its `core` holds the bounded
contexts. A module that is a **single** bounded context has no component
wrapper: `application/`, `domain/` and `port/` sit directly under `core/`.
Naming a component after the module's own subject is the anti-pattern — the
subject names the module, not a component (`Shop` is not a component of the
shop app). A module that wraps **several** contexts groups them under
`core/<component>/`, each with its own `application/` + `domain/`. A component
has no `ui` and no `infrastructure`: those exist only where something is
delivered or adapted, and a component is neither. The shape bottoms out here.
Never add empty `ui`/`infra` folders "for symmetry" — they imply a delivery
surface that isn't there.

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
| `core/application/`             | `actions/` (`Action`), `data/` (`DataTransferObject`), `queries/` (`Query`), `services/` (`Service`), `listeners/` (`Listener`), repository interfaces |
| `core/domain/`                  | `models/` (bare), `enums/` (descriptive: `PostStatus`), `events/` (`Event`), `errors/` (`Error`), `rules/` (`Rule`), domain services (`Service`) |
| `core/port/`                    | `Port` interfaces, plus the value objects, DTOs, builders and query objects they need |
| `ui/`                           | `controllers/`, `commands/`, `requests/`, `resources/`, `view-models/`, `scheduling/` |
| `infrastructure/<tool>/`        | `Adapter` — one subfolder per tool; a second vendor adapter earns a per-vendor subfolder |

In a module that wraps several bounded contexts, the `core/application/` and
`core/domain/` rows nest one level deeper, under `core/<component>/`.

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
