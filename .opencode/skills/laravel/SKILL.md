---
name: laravel
description: The user's Laravel mechanics — modular monolith as Composer packages, hexagonal-flavored App/Domain/Infrastructure layering, action objects + DTOs, ServiceProvider bootstrap, composer wiring, and Pest + Testbench testing. The concrete Laravel expression of the software-architecture contract. Use when building, extending, or reviewing a Laravel module or application in the user's style, or when the user references their modules, action objects, DTOs, ServiceProvider, or composer wiring.
---

# laravel

The user's Laravel mechanics: a **modular monolith** of Composer packages, each
with **hexagonal-flavored layering** (App/Domain/Infrastructure), using
**action objects + DTOs** for use cases, and **Pest + Testbench** for testing.
This is the _how we do it here_ in Laravel, grounded in the user's repos
(`laravel-skeleton`, `laravel-package-skeleton`, `laravel-module-support`,
`laravel-module-news`, `laravel-module-user`).

The general architecture contract (language-agnostic) lives in the
`software-architecture` skill; the Filament admin UI mechanics live in the
`filament` skill. Load those for the reasoning; this skill is the Laravel
mechanics.

## When to use

- Building a new Laravel module or application in the user's style.
- Extending an existing module (new action, DTO, migration, ServiceProvider).
- Reviewing Laravel code against the user's conventions.
- The user references their modules, action objects, DTOs, ServiceProvider, or
  composer wiring.

## How a Laravel app with this architecture looks

A host Laravel app is built on the `laravel-package-skeleton` folder structure
and pulls in modules as Composer packages. Each module is a bounded context with
its own hexagonal-flavored layering (`App/`/`Domain/`/`Infrastructure/`); the UI
reaches the domain only through actions + DTOs. The modules are Composer
dependencies resolved into `vendor/` — they are not nested in the project tree.
The project's `src/` holds only app-specific code; each module brings its own
`src/` (with its own layers) inside its package.

The flow for a write operation: **UI page → `PostData::fromArray(...)` →
`app(CreatePostAction::class)` → Eloquent model**. The page never touches
Eloquent directly; the action is the single seam.

## Module structure (the skeleton)

A module is a Composer package, PSR-4 root `Lines\<Module>\` → `src/`:

```
laravel-module-<name>/
├── src/
│   ├── <Module>ServiceProvider.php   # Package bootstrap (Spatie PackageServiceProvider)
│   ├── App/                          # UI layer (Filament + Livewire)
│   │   ├── Console/Commands/         # artisan commands
│   │   ├── Filament/                 # see the filament skill
│   │   ├── Livewire/                 # public-facing components
│   │   └── Providers/
│   ├── Domain/                       # Domain layer
│   │   ├── Actions/                  # *Action (invokable use cases)
│   │   ├── DataTransferObjects/      # *Data (readonly DTOs)
│   │   ├── Enums/                    # *Status (string enums, state machines)
│   │   └── Models/                   # Eloquent models (no suffix)
│   └── Infrastructure/               # adapters (empty until needed)
├── database/
│   ├── factories/                    # *Factory (fluent states)
│   ├── migrations/                   # create_*_table
│   └── seeders/                      # DatabaseSeeder
├── resources/views/                  # Blade views (<module>:: namespace)
├── routes/web.php                    # <module>.* named routes
├── stubs/                            # publishable stubs
├── tests/                            # Pest + Testbench
│   ├── Pest.php, TestCase.php
│   ├── Unit/Domain/...               # mirror src/Domain
│   ├── Feature/App/...               # mirror src/App
│   └── Browser/
└── workbench/                        # Testbench host app (panel, models, migrations)
```

## Naming conventions

| Kind              | Suffix                    | Example               |
| ----------------- | ------------------------- | --------------------- |
| Action            | `*Action`                 | `CreatePostAction`    |
| DTO               | `*Data`                   | `PostData`            |
| Enum              | `*Status`                 | `PostStatus`          |
| Model             | (none)                    | `Post`                |
| Factory           | `*Factory`                | `PostFactory`         |
| ServiceProvider   | `*ServiceProvider`        | `NewsServiceProvider` |

**Module repo names are singular** (`laravel-module-todo`, `laravel-module-news`,
`laravel-module-user`), matching the PSR-4 root `Lines\<Module>\`.

(Filament naming — `*Resource`, `*Plugin`, `*Form`, `*Table`, `Create*`/`Edit*`/
`List*` pages — lives in the `filament` skill.)

## Action objects + DTOs

**Action** — a single-responsibility command, `final`, invokable, DTO in →
model out. An action may compose **zero or more nested actions** (each with its
own single responsibility), following SOLID single-responsibility:

```php
// src/Domain/Actions/CreatePostAction.php
final readonly class CreatePostAction
{
    public function __construct(
        private RecordPostCreatedAction $recordAuditTrail,
    ) {}

    public function __invoke(PostData $data): Post
    {
        return DB::transaction(function () use ($data) {
            $post = Post::create([
                'author_id' => $data->author_id,
                'title'     => $data->title,
                'body'      => $data->body,
                'status'    => $data->status->value,
                'published_at' => $data->published_at,
            ]);

            ($this->recordAuditTrail)($post);

            return $post;
        });
    }
}
```

- **Constructor injection** — nested actions and dependencies are injected via
  the constructor, never `app()`/`resolve()` inside the body.
- **`DB::transaction()`** — multi-write operations are wrapped.
- **Composition:** a high-level action orchestrates by calling lower-level
  actions, each with one reason to change.
- No UI concerns; calls Eloquent directly (no repository).

**DTO** — readonly, extends the shared module-support base, `casts()` for
coercion:

```php
// src/Domain/DataTransferObjects/PostData.php
final readonly class PostData extends DataTransferObject
{
    protected static function casts(): array
    {
        return [
            'published_at' => fn ($value) => self::castCarbonOrNull($value),
            'status' => fn ($value, $data) => self::computedStatus($data),
        ];
    }

    protected function __construct(
        public ?string $id,
        public int $author_id,
        public string $title,
        public string $body,
        public PostStatus $status,
        public ?CarbonImmutable $published_at,
    ) {}

    private static function castCarbonOrNull(?string $value): ?CarbonImmutable
    {
        return ! is_null($value) ? CarbonImmutable::parse($value) : null;
    }

    private static function computedStatus(array $data): PostStatus
    {
        return match (true) {
            is_null($data['published_at']) => PostStatus::Draft,
            CarbonImmutable::parse($data['published_at'])->isPast() => PostStatus::Published,
            else => PostStatus::Scheduled,
        };
    }
}
```

- Extends `Lines\Support\Domain\DataTransferObjects\DataTransferObject`
  (reflection-based `fromArray()` + `casts()` contract).
- **`casts()`** is `protected static`, returning a map of field → cast
  function; each cast receives `($value, $data)`.
- `fromArray([...])` is the factory used by pages.

## ServiceProvider (module bootstrap)

`src/<Module>ServiceProvider.php` extends
`Spatie\LaravelPackageTools\PackageServiceProvider` and declares the whole
surface: config, views, translations, assets, routes, migrations, commands,
Livewire namespace, Filament assets. Registered via composer
`extra.laravel.providers`.

## Composer wiring (how modules tie together)

A **project app** (built on `laravel-package-skeleton`) pulls in modules as
Composer packages. The modules are resolved into `vendor/` — they are not
nested in the project tree. Each module is itself a Composer package with its
own `composer.json`, declaring its own dependencies (on other modules and the
shared kernel) and its `*ServiceProvider`.

### Production composer.json (the happy path)

In production, the project requires the published packages by version
constraint. Composer resolves them from Packagist (or a private registry):

```json
{
    "require": {
        "php": "^8.2",
        "99linesofcode/laravel-module-news": "^1.0",
        "99linesofcode/laravel-module-user": "^1.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    }
}
```

No `repositories` block is needed — the modules are published packages. Each
module's own `composer.json` declares its `extra.laravel.providers`, so the
host app knows which `*ServiceProvider` to boot.

### Including a module in development (local machine)

When you're working on a module and the host app together, point Composer at
the local copy with a **path repository**. This symlinks the local module into
`vendor/` so edits are picked up immediately:

```json
{
    "repositories": [
        {
            "type": "path",
            "url": "../laravel-module-news",
            "options": { "symlink": true }
        }
    ],
    "require": {
        "php": "^8.2",
        "99linesofcode/laravel-module-news": "@dev"
    },
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    }
}
```

The path repository (`"type": "path"`, `"url": "../laravel-module-news"`,
`"options": { "symlink": true }`) tells Composer to use the local checkout
instead of the published package. The `@dev` stability flag allows the
unreleased local version. This is a **development-only** convenience — it's
dropped in production, where the module is referenced as a published package
with a real version constraint.

### Module-to-module dependencies

A module's own `composer.json` declares its dependencies on other modules and
the shared kernel the same way — with path repositories in dev, published
packages in production. Each module owns a `Lines\*` namespace
(`Lines\News\`, `Lines\Auth\`), so cross-module references are explicit, and
registers its `*ServiceProvider` via `extra.laravel.providers`.

## Testing (Pest + Testbench)

- **Pest** with `tests/Pest.php` binding a `TestCase` (extends
  `Orchestra\Testbench\TestCase`, uses `RefreshDatabase` + `WithWorkbench`).
- **Layout mirrors source**: `tests/Unit/Domain/...` and
  `tests/Feature/App/...` mirror `src/`.
- **What's tested**: action behavior (DB assertions via
  `assertDatabaseHas`/`assertDatabaseCount`), DTO casting/computed fields, enum
  state transitions, Filament form validation rules, table columns/sorting,
  page render + create/edit flows via `livewire(...)` and
  `Filament::setCurrentPanel`.
- **Fixtures**: factories with fluent states (`draft()`, `scheduled()`,
  `published()`, `existing()`).
- **Naming**: `describe('CreatePostAction', ...)` / `it('creates a post', ...)`;
  nested `describe` for states. See the `software-testing` skill for the
  BDD/TDD contract.

## Models, migrations & workbench

Models use **UUID primary keys** (`HasUuids` + `uuid('id')->primary()` +
`foreignUuid`), which drives the DTO `id` type (`?string`). The workbench is
the Testbench host that runs the module's Filament panel (registers the plugin,
needs a `UserFactory`, and `filament:assets` before serving). Full detail:
`references/models-and-migrations.md` and `references/workbench.md`.

## Gotchas

- **UI never calls Eloquent directly** — always through an action + DTO.
- **Domain has no UI imports** — `src/Domain/` must not import Filament/Livewire.
- **`Infrastructure/` stays empty until there's a real adapter need** — don't
  add ports/adapters speculatively (lean guardrail).
- **Models carry framework traits** (`HasUuids`, `SoftDeletes`, `#[UseFactory]`)
  — Eloquent is persistence + domain model combined; that's accepted.
- **Cross-module deps** via `Lines\*` namespaces (e.g. `Post::author()` belongs
  to `Lines\Auth\Domain\Models\User`); shared support comes from
  `laravel-module-support`.
- **New modules** start from `laravel-skeleton` / `laravel-package-skeleton`
  (consumed via git remote + rebase).

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-architecture` (the general contract), `filament`
  (the Filament UI mechanics), `software-testing` (the testing contract).
- Wiki concepts (under `~/Documents/Obsidian/AI/wiki/concepts/`): `ddd.md`,
  `hexagonal-architecture.md`, `action-objects.md`, `modular-monolith.md`,
  `software-architecture-principles.md`.
- Reference repos: `~/Development/laravel-skeleton`, `laravel-package-skeleton`,
  `laravel-module-support`, `laravel-module-news`, `laravel-module-user`.
