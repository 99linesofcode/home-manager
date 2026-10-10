---
name: rails
description: The user's Ruby on Rails mechanics — the Rails-engine-as-module layout, the engine composition root, ActiveRecord mechanics, Action objects + DTOs, Hotwire (Turbo + Stimulus) UI, Packwerk boundary enforcement, and RSpec testing. The Ruby/Rails expression of the software-architecture contract and the sibling of the laravel skill. Use when building, extending, or reviewing Ruby on Rails code, engines, modules, action objects, DTOs, ActiveRecord models, Hotwire views, or Packwerk boundaries in the user's repos.
---

# rails

The user's Ruby on Rails mechanics — the Ruby/Rails-specific conventions for the
user's repos (`rails-skeleton`, `rails-package-skeleton`, `rails-module-*`): the
engine-as-module layout,
the engine composition root, ActiveRecord mechanics, Action objects + DTOs, the
Hotwire UI seam, Packwerk boundary enforcement, and RSpec testing.

The architecture — the module-first structure, the layers, the role suffixes,
where logic lives — is **single-sourced in the `software-architecture` skill**
and applies to every language. This skill adds only what is specific to
Rails/Ruby, and never restates the architecture. Where this skill's structure
and Rails' own convention conflict, **Rails' convention wins** (Zeitwerk, the
generators, `app/`) — exactly as `software-architecture` says language
conventions do — as long as the module boundary stays expressible.

## When to use

- Building a new Rails app or engine module in the user's style.
- Extending an existing engine (new action, DTO, migration, engine wiring).
- Reviewing Rails code against the user's conventions.
- The user references their Rails modules, engines, action objects, DTOs,
  ActiveRecord models, Hotwire, or Packwerk.

## How a Rails app is wired

A host Rails app is the deployable. It pulls in modules as **Rails engines** —
each engine is a miniature Rails app with its own `app/`, routes, migrations,
and namespace, mounted by the host. Engines are packaged as gems in production
(versioned, resolved by Bundler) and consumed via path or Git sources in
development. The host's `app/` holds only app-specific code.

This mirrors the Laravel fleet exactly: a Laravel module is a Composer package;
a Rails module is an engine gem. The Laravel `*ServiceProvider` composition root
becomes the engine class; Composer's `extra.laravel.providers` becomes the
engine's autoload and mount; the `laravel-module-support` shared kernel becomes
the `rails-module-support` gem.

The write flow is the same seam: **controller/component →
`PostDataTransferObject.new(...)` → `CreatePostAction.new(...).call` →
ActiveRecord model**. The UI never touches ActiveRecord directly; the action is
the single seam.

## Package layout (the skeleton)

Two repositories are the source, mirroring `laravel-skeleton` /
`laravel-package-skeleton`. Neither exists yet; this is the shape they are built
to. The module's layout is the engine tree in "The module is an engine" above.

**`rails-skeleton` — the app** (the deployable):

```
rails-skeleton/
├── app/                      # app-specific code only (the host's own layers)
├── config/                   # application.rb (loads the engines), routes,
│                             #   deploy.yml (Kamal), initializers
├── db/  lib/  spec/          # app-level migrations, infrastructure, specs
├── Gemfile                   # rails ~> 8.1, ruby 3.4; solid_queue/cache/cable;
│                             #   avo, packwerk, rspec-rails, rubocop, brakeman
├── .envrc + flake.nix        # devshell
├── .github/workflows/        # CI gates
├── kamal/                    # deploy
└── ARCHITECTURE.md  AGENTS.md  README.md
```

**Gates (CI, both repos):** `bundle exec rspec`, `bundle exec rubocop`,
`bin/packwerk check`, `bundle exec brakeman` — all green; `packwerk check` is
the boundary gate. **Shared kernel:** `rails-module-support`, its own engine gem
(the analog of `laravel-module-support`).

When the repos exist, `new-project` gains a Rails branch: an app from
`rails-skeleton`, a module from `rails-package-skeleton`.

## The module is an engine

A module is a **Rails engine** — the structural boundary. The engine gives you
what a Laravel module package gives you: an isolated namespace, its own routes
and helpers, its own migrations with a table-name prefix, and an independent
test suite via its own dummy app.

```
rails-module-news/                  # the module IS the repo (an engine gem)
├── lib/
│   └── lines/
│       └── news/
│           ├── engine.rb           # the composition root (< Rails::Engine)
│           └── version.rb
├── app/                            # the engine's Rails-conventional interior
│   ├── controllers/                # UI (driving adapters) — thin
│   ├── components/                 # UI (ViewComponent)
│   ├── views/                      # ERB / Hotwire templates
│   ├── avo/                        # UI — Avo resources/actions/dashboards/cards
│   ├── actions/                    # core application — *Action (use cases)
│   ├── queries/                    # core application — *Query
│   ├── data/                       # core application — *DataTransferObject
│   ├── models/                     # core domain — ActiveRecord models (lean)
│   ├── services/                   # core domain services
│   ├── ports/                      # core — port interfaces
│   ├── adapters/                   # driven adapters (infrastructure)
│   └── jobs/                       # infrastructure (Active Job)
├── config/
│   ├── routes.rb                   # the engine's routes (isolate_namespace)
│   └── initializers/               # wiring
├── db/migrate/                     # engine migrations (prefixed tables)
├── spec/                           # RSpec, mirrors app/
├── spec/dummy/                     # the engine's host app (the Testbench analog)
├── package.yml                     # Packwerk package definition
└── news.gemspec
```

**The engine is the module; the interior is Rails-conventional.** Rails
autoloads `app/`, so the architecture's layers are expressed as **role folders
under `app/`** and enforced by the engine boundary plus Packwerk — not by a
literal `ui/core/infrastructure` tree. A literal layer tree fights Zeitwerk (a
file's path must match its constant) and the generators, and
`software-architecture` says the language's convention wins where the boundary
stays expressible. This is the one deliberate divergence from the Laravel
expression, and it is explicit.

## Naming conventions (Rails-specific roles)

The canonical role → suffix table — `Action`, `DataTransferObject`, `Query`,
`Service`, `Event`, `Listener`, `Port`, `Adapter`, `Mapper`, `Error`, `Rule`,
`State` — lives in `software-architecture`. Rails adds only the
framework-specific roles:

| Kind          | Suffix         | Example             |
| ------------- | -------------- | ------------------- |
| Controller    | `*Controller`  | `PostsController`   |
| ViewComponent | `*Component`   | `PostCardComponent` |
| Presenter     | `*Presenter`   | `PostPresenter`     |
| Form object   | `*Form`        | `PostForm`          |
| Job           | `*Job`         | `PublishPostJob`    |
| Mailer        | `*Mailer`      | `PostMailer`        |
| Policy        | `*Policy`      | `PostPolicy`        |

Models are bare (`Post`); engines are namespaced under the `Lines` root —
`Lines::News::Engine`, `isolate_namespace Lines::News` — mirroring the Laravel
`Lines\News` PSR-4 root. Module repo names are singular (`rails-module-news`).

## Action objects + DTOs

**Action** — a single-responsibility use case, `call` as the single public
method, DTO in, model out. Dependencies arrive via constructor injection, never
resolved inside the body. An action composes zero or more nested actions.

```ruby
# app/actions/create_post_action.rb
class CreatePostAction
  def initialize(audit_trail: RecordPostCreatedAction.new)
    @audit_trail = audit_trail
  end

  def call(data)
    Post.transaction do
      post = Post.create!(author_id: data.author_id, title: data.title,
                          status: data.status)
      @audit_trail.call(post)
      post
    end
  end
end
```

- `call` is the single public method — Ruby's idiomatic counterpart to PHP's
  `__invoke`.
- Constructor injection for nested actions and collaborators; wire them in the
  engine's composition root.
- Wrap multi-write operations in `ActiveRecord::Base.transaction`.
- No UI concerns; ActiveRecord is called directly (no repository over
  ActiveRecord — the lean guardrail).

**DTO** — an immutable, canonical payload at the boundary. Prefer Ruby's native
`Data.define` (Ruby 3.2+) for a lean shape; reach for `dry-struct` when coercion
or type enforcement is needed. Name it for the concept, not the operation
(`PostDataTransferObject`, never `CreatePostParams`), and keep **one canonical
DTO per domain concept**.

```ruby
# app/data/post_data_transfer_object.rb
class PostDataTransferObject < Data.define(:id, :author_id, :title, :body,
                                           :status, :published_at)
  def self.from_params(params)
    new(id: params[:id],
        author_id: params[:author_id],
        title: params[:title],
        body: params[:body],
        status: PostStatus.new(params[:status]),
        published_at: params[:published_at] && Time.zone.parse(params[:published_at]))
  end
end
```

A shared DTO base — when one earns its keep — lives in the
`rails-module-support` gem, mirroring Laravel's `DataTransferObject` base.

## The composition root (engine)

`lib/lines/<module>/engine.rb` is the engine's **composition root** — the one
place where wiring and interface bindings happen, mirroring Laravel's
`*ServiceProvider`. It declares the engine's surface: routes, migrations,
initializers, and the bindings for ports and adapters.

```ruby
# lib/lines/news/engine.rb
module Lines
  module News
    class Engine < ::Rails::Engine
      isolate_namespace Lines::News

      initializer "lines.news.bindings" do
        # wire ports → adapters here (the composition root)
      end
    end
  end
end
```

- `isolate_namespace` is the engine's whole point: it scopes models, routes,
  helpers, and table-name prefixes to the `Lines::News` namespace.
- Keep wiring here; never scatter `Rails.application.config` lookups through
  class bodies. Add a DI container (`dry-system`) only when a real need appears
  (lean guardrail).

## ActiveRecord mechanics (lean models)

Models are data + identity: attributes, associations, scopes, minimal callbacks
— nothing else. Behavior lives in actions, query objects, value objects, and
domain services; the model stops being the dumping ground.

- **No calculations in the model.** A computed value is calculated by an action
  and stored; reading it is plain data.
- **Scopes → query objects.** Repeated query logic moves to a `*Query` class
  (`app/queries/published_posts_query.rb`); a one-off scope stays a scope.
- **States → `enum` or a state object.** Use `enum` for simple states; a state
  object when transitions multiply.
- **Value objects for invariants.** A `Money`/`Email`/`Slug` that enforces a
  rule earns its class; a wrapper that only re-types a primitive does not.
- **Migrations** live in the engine's `db/migrate`; tables are prefixed by
  `isolate_namespace`.
- **No repository over ActiveRecord** unless a real storage-swap seam exists.

## The UI seam (Hotwire) + admin

The UI is a thin delivery adapter that calls actions. Rails' default frontend is
**Hotwire** (Turbo + Stimulus) over server-rendered ERB — interactive UI without
a JS SPA and without a client build. Keep the browser dumb.

- **Controllers** stay thin: build the DTO, call the action, render or redirect.
- **Turbo Frames/Streams** swap server-rendered fragments; **Stimulus** covers
  the occasional client sprinkle. No SPA, no npm build (import maps +
  Propshaft).
- **ViewComponents** (`*Component`) for reusable view pieces.
- **The admin and interface surface is Avo** (the `avo` skill) — the Rails
  counterpart of Filament, a Hotwire + Tailwind Rails engine that renders
  resource-based CRUD, Actions, dashboards, and cards over the app's models. It
  covers the admin **and** the customer-facing interface. Avo pages display
  records and route mutations through an Avo Action → core `*Action`; they never
  write through the model directly.

## Testing (RSpec + the engine dummy app)

- **RSpec** (the Pest analog), mirroring the source layout — the mirroring
  contract is in `software-testing`.
- **Engine tests run against the engine's dummy app** — the analog of Laravel's
  Testbench workbench. Each engine is testable without the host app.
- **What's tested**: action behavior (DB assertions), DTO mapping, enum and
  state transitions, and the boundary (Packwerk). UI/Hotwire testing is a
  per-project choice.
- **Factories** (FactoryBot) with traits for states.

## Boundary enforcement (Packwerk)

The module boundary is enforced **mechanically**, not by convention — the
Deptrac analog. Use both layers:

- **The engine** gives the structural boundary: isolated namespace, routes,
  helpers, prefixed tables, independent tests.
- **Packwerk** gives the CI gate: a `package.yml` per package, `app/public/` as
  the deliberate public API, and `bin/packwerk check` failing the build on a
  violation. Run it in CI; a violation is a blocking finding.

Engines alone do not hard-block cross-engine constant access at runtime (the
host eager-loads them all), so Packwerk is what makes the boundary enforceable
in the build. Ship the gate.

## Gotchas

- **The UI never calls ActiveRecord directly** — always through an action + DTO.
- **A literal `ui/core/infrastructure` tree fights Zeitwerk** — use role folders
  under `app/`; the engine is the boundary.
- **Cross-module access goes through the shared kernel or events**, never a peer
  engine's internals; Packwerk enforces it.
- **Keep the composition root in the engine** — no `Rails.application` lookups
  in class bodies.
- **Rails 8 defaults** — Solid Queue/Cache/Cable (no Redis), Kamal 2 + Thruster
  for deploy, Propshaft + import maps (no client build), Hotwire for UI, SQLite
  viable in production. Don't reintroduce Redis or an npm build without cause.
- **New modules** start from `rails-package-skeleton`; new apps from
  `rails-skeleton` (consumed via git remote + rebase).

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-architecture` (the single source of truth for the
  architecture), `software-testing` (the testing contract), `avo` (the admin UI
  mechanics), `laravel` (the PHP sibling this mirrors).
- Reference repos (target): `~/Development/rails-skeleton` (app),
  `rails-package-skeleton` (module/engine template), `rails-module-*` (modules).
- `references/activerecord.md` — the ActiveRecord mechanic (UUID keys, lean
  models).
- `references/dummy-app.md` — the engine's host app (the Testbench analog).
- Wiki concepts: `modular-monolith.md`, `hexagonal-architecture.md`,
  `action-objects.md`, `architecturally-evident-structure.md`.
