---
name: avo
description: The user's Avo admin UI mechanics — Resources, Fields, Actions, Dashboards, Cards, and the Avo-to-action seam. The concrete Avo expression of the software-architecture contract, layered on the rails skill. Use when building, extending, or reviewing Avo resources, fields, actions, dashboards, cards, or authorization in the user's Rails modules or applications.
---

# avo

The user's Avo admin UI mechanics. Avo is the admin UI layer of the user's
Rails modules — a Rails engine built on Hotwire (Turbo + Stimulus) and Tailwind
that renders a resource-based CRUD interface, custom Actions, dashboards, and
cards over the app's existing models. It is the Rails counterpart of Filament:
the higher-level abstraction for building the admin **and** the customer-facing
interface, composed from existing components or built from scratch.

Avo is the **UI → core seam**: an Avo resource displays records; an Avo Action
builds a DTO and calls a core action. It never writes through the model
directly.

The general architecture contract lives in the `software-architecture` skill;
the Rails mechanics (engines, actions/DTOs, Hotwire, Packwerk) live in the
`rails` skill. Load those for the reasoning; this skill is the Avo mechanics.

## When to use

- Building or extending an Avo resource, field, action, dashboard, or card.
- Reviewing Avo code against the user's conventions.
- The user references Avo resources, fields, actions, dashboards, or cards.

## The Avo → action seam

The flow for a write operation: **Avo Action → `PostDataTransferObject.new(...)`
→ `CreatePostAction.new(...).call` → ActiveRecord model**. The Avo layer never
writes through the model directly; the action is the single seam. Resources
(reads) display model data; Actions (writes) route through the core.

## Module structure (Avo part)

Avo's files live under `app/avo/`, inside each module's engine:

```
app/avo/
├── resources/            # *Resource  (Avo::Resources::X < Avo::BaseResource)
├── actions/              # *Action    (Avo::Actions::X < Avo::BaseAction)
├── dashboards/           # *Dashboard
└── cards/                # *Card (metrics, charts)
```

Because Avo is a Rails engine, its routes are isolated — prepend the engine
name (`avo.` / `main_app.`) when using path helpers.

## Naming conventions

| Kind      | Suffix       | Example                     |
| --------- | ------------ | --------------------------- |
| Resource  | `*Resource`  | `Avo::Resources::Post`      |
| Action    | `*Action`    | `Avo::Actions::PublishPost` |
| Dashboard | `*Dashboard` | `SalesDashboard`            |
| Card      | `*Card`      | `Avo::Cards::MrrMetric`     |

Avo classes are namespaced under `Avo::` per Avo's convention. A resource maps
one model (multiple resources per model are allowed); its model is inferred from
the class name unless `self.model_class` overrides it.

## Resource

A **Resource** declares the fields and the actions; Avo renders the Index, Show,
and form views, the associations, and the search:

```ruby
# app/avo/resources/post.rb
class Avo::Resources::Post < Avo::BaseResource
  self.title = :title
  self.includes = [:author]

  def fields
    field :id, as: :id
    field :title, as: :text, required: true
    field :status, as: :badge, enum: ::Post.statuses
    field :published_at, as: :date_time
    field :author, as: :belongs_to
    field :body, as: :textarea, hide_on: :index
  end

  def actions
    action Avo::Actions::PublishPost
  end
end
```

- `self.title` — the attribute a human recognizes.
- `self.includes` — preload associations so Index doesn't fire a query per row.
- `self.search` — a ransack query across the fields people look records up by.
- Match field types to the columns deliberately: `badge` for a status enum,
  `select` for an editable enum, `money` for currency, `file` for Active
  Storage, `belongs_to`/`has_many` for associations, `hide_on: :index` for long
  text.

## Fields

`field DATABASE_COLUMN, as: FIELD_TYPE, **OPTIONS`. View-specific methods
(`index_fields`, `show_fields`, `edit_fields`, `new_fields`) override the default
`fields`; `display_fields` and `form_fields` cover view groups. Use
`hide_on`/`show_on` for view targeting; a field block runs with `record`,
`resource`, and `current_user` available.

## Actions (the UI → Domain seam)

An **Action** is a plain Ruby class with a `handle` method, registered on a
resource. This is where writes go through the core:

```ruby
# app/avo/actions/publish_post.rb
class Avo::Actions::PublishPost < Avo::BaseAction
  self.name = "Publish post"

  def handle(query:, **)
    query.each do |post|
      PublishPostAction.new.call(PostDataTransferObject.from_record(post))
    end

    succeed "Published the selected posts."
  end
end
```

- `handle` receives `query` (the selected records, wrapped in an array),
  `fields` (modal inputs), `current_user`, `resource`, and `request`.
- The real work lives in the core `*Action`, not in the Avo action — the Avo
  action is a thin trigger that builds the DTO and calls it.
- Feedback via `succeed`/`inform`/`warn`/`error`; the response via `reload`,
  `redirect_to`, `download`, `reload_records`, and the like.
- `visible` and `authorize` control where and for whom the action appears;
  authorization is re-checked on execution.

## Dashboards and cards

Dashboards compose cards (metrics, charts) and resources:

```ruby
class Avo::Dashboards::SalesDashboard < Avo::BaseDashboard
  def cards
    card Avo::Cards::MrrMetric, cols: 3
    card Avo::Cards::SignupsChart, cols: 6
  end
end
```

## Authorization (Pundit)

Avo reads permissions from Pundit policies (`config.authorization_client = :pundit`).
The methods Avo calls: `index?`, `show?`, `new?`, `create?`, `edit?`, `update?`,
`destroy?`, `act_on?`, `search?`, `reorder?`, `preview?`; plus per-association
(`view_comments?`, `attach_comments?`) and per-file (`upload_cover_photo?`)
methods. A `Scope` filters the Index query to the rows a user may see;
`whitelisted_fields` / `blacklisted_fields` hide fields a user may not reach. A
missing policy denies (with `explicit_authorization` on).

## Gotchas

- **The Avo layer never writes through the model directly** — mutations go
  through an Avo Action → core `*Action`; resources display, actions mutate.
- **The core must not import Avo** — the UI layer is one-way.
- **Avo is a Rails engine** — its routes are isolated; prepend the engine name
  to path helpers.
- **`self.includes` matters** — a resource without preloads fires a query per
  row on Index.
- **Avo 4 is Hotwire + Tailwind**, not jQuery, and works with Propshaft as well
  as Sprockets.
- **Licensing:** the Community tier is free and covers resources, fields,
  associations, actions, and basic filters; authorization, dashboards, global
  search, scopes, dynamic filters, kanban, and audit logging are paid add-ons
  per app. Confirm which tier a feature needs before relying on it.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `rails` (the Rails mechanics), `software-architecture` (the
  general contract), `software-testing` (the testing contract).
- Wiki concepts: `action-objects.md`, `hexagonal-architecture.md`.
- Reference repos (target): `~/Development/rails-module-*`.
