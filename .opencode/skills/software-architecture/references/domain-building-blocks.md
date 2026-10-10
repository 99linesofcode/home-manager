# Domain building blocks & patterns

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
