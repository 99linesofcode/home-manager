---
name: laravel
description: The user's Laravel mechanics — the PHP/Laravel-specific conventions for the user's repos: composer wiring, the ServiceProvider composition root, Eloquent model mechanics, Pest + Testbench testing, and the Laravel-specific naming roles. Architecture itself lives in the software-architecture skill. Use when building, extending, or reviewing Laravel code in the user's style, or when the user references their modules, ServiceProvider, composer wiring, or Eloquent mechanics.
---

# laravel

The user's Laravel mechanics — the PHP/Laravel-specific conventions for the
user's repos (`laravel-skeleton`, `laravel-package-skeleton`,
`laravel-module-support`, `laravel-module-news`, `laravel-module-user`):
composer wiring, the ServiceProvider composition root, Eloquent model
mechanics, and Pest + Testbench testing.

The architecture — the module-first directory structure, the layers, the role
suffixes, where logic lives — is **single-sourced in the `software-architecture`
skill** and applies to every language. This skill adds only what is specific to
Laravel/PHP, and never restates the architecture. The Filament admin UI
mechanics live in the `filament` skill.

## When to use

- Building a new Laravel module or application in the user's style.
- Extending an existing module (new action, DTO, migration, ServiceProvider).
- Reviewing Laravel code against the user's conventions.
- The user references their modules, action objects, DTOs, ServiceProvider, or
  composer wiring.

## How a Laravel app is wired

A host Laravel app is built on the `laravel-package-skeleton` and pulls in
modules as Composer packages. The modules are dependencies resolved into
`vendor/` — they are not nested in the project tree; each brings its own `src/`
inside its package. The project's `src/` holds only app-specific code.

The Laravel expression of a write flow: **UI page →
`PostDataTransferObject::fromArray(...)` → `app(CreatePostAction::class)` →
Eloquent model**. The page never touches Eloquent directly; the action is the
single seam. The structure and the naming are in `software-architecture`.

## Package layout (the skeleton)

A module is a Composer package, PSR-4 root `Lines\<Module>\` → `src/`. The
`src/` interior follows `software-architecture` (module-first); this is only
the Laravel-specific scaffolding around it:

```
laravel-module-<name>/
├── src/                              # interior per software-architecture
│   └── <Module>ServiceProvider.php   # composition root (Spatie PackageServiceProvider)
├── database/
│   ├── factories/                    # *Factory (fluent states)
│   ├── migrations/                   # create_*_table
│   └── seeders/                      # DatabaseSeeder
├── resources/views/                  # Blade views (<module>:: namespace)
├── routes/web.php                    # <module>.* named routes
├── stubs/                            # publishable stubs
├── tests/                            # Pest + Testbench (mirrors src/; see software-testing)
│   ├── Pest.php, TestCase.php
└── workbench/                        # Testbench host app (panel, models, migrations)
```

## Naming conventions (Laravel-specific roles)

The canonical role → suffix table — `Action`, `DataTransferObject`, `Enum`,
`Model`, `Event`, `Rule`, and the rest — lives in `software-architecture`.
Laravel adds only the framework-specific roles:

| Kind            | Suffix             | Example               |
| --------------- | ------------------ | --------------------- |
| QueryBuilder    | `*QueryBuilder`    | `PostQueryBuilder`    |
| Collection      | `*Collection`      | `PostLineCollection`  |
| Factory         | `*Factory`         | `PostFactory`         |
| ServiceProvider | `*ServiceProvider` | `NewsServiceProvider` |

**Module repo names are singular** (`laravel-module-todo`, `laravel-module-news`,
`laravel-module-user`), matching the PSR-4 root `Lines\<Module>\`.

(Filament naming — `*Resource`, `*Plugin`, `*Form`, `*Table`, `Create*`/`Edit*`/
`List*` pages — lives in the `filament` skill.)

## Action objects + DTOs

**Action** — a single-responsibility command, `final`, invokable, DTO in →
model out. An action may compose **zero or more nested actions** (each with its
own single responsibility), following SOLID single-responsibility:

```php
// CreatePostAction.php
final readonly class CreatePostAction
{
    public function __construct(
        private RecordPostCreatedAction $recordAuditTrail,
    ) {}

    public function __invoke(PostDataTransferObject $data): Post
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
// PostDataTransferObject.php
final readonly class PostDataTransferObject extends DataTransferObject
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

- Extends the shared `DataTransferObject` base from `laravel-module-support`
  (reflection-based `fromArray()` + `casts()` contract).
- **`casts()`** is `protected static`, returning a map of field → cast
  function; each cast receives `($value, $data)`.
- `fromArray([...])` is the factory used by pages.

## ServiceProvider (module bootstrap)

`src/<Module>ServiceProvider.php` extends
`Spatie\LaravelPackageTools\PackageServiceProvider` and declares the whole
surface: config, views, translations, assets, routes, migrations, commands.
Registered via composer `extra.laravel.providers`. It is the module's **composition root**: the one
place where wiring and interface bindings happen — never `app()`/`resolve()`
inside class bodies.

## Composer wiring (how modules tie together)

A **project app** (built on `laravel-package-skeleton`) pulls in modules as
Composer packages. The modules are resolved into `vendor/` — they are not
nested in the project tree. Each module is itself a Composer package with its
own `composer.json`, declaring its own dependencies (on other modules and the
shared kernel) and its `*ServiceProvider`.

**The shared kernel is itself a module:** `laravel-module-support` is a
shared component — Graça's SharedKernel expressed as a Composer package. It
holds framework-grade, conceptually cohesive code that could have been part
of the framework (the `DataTransferObject` base, cross-cutting concerns).
Inside a module, a `Support/` subfolder is the legitimate staging area for
generic, universal concepts on their way to extraction into their own
package; there is no `Utils/`/`Helpers/` dump anywhere.

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
- **Layout mirrors source** — the mirroring contract is in `software-testing`.
- **What's tested**: action behavior (DB assertions via
  `assertDatabaseHas`/`assertDatabaseCount`), DTO casting/computed fields, enum
  state transitions. (Filament/UI testing lives in the `filament` skill.)
- **Fixtures**: factories with fluent states (`draft()`, `scheduled()`,
  `published()`, `existing()`).
- **Naming**: `describe('CreatePostAction', ...)` / `it('creates a post', ...)`;
  nested `describe` for states. See the `software-testing` skill for the
  BDD/TDD contract.

## Models, migrations & workbench

Models use **UUID primary keys** (`HasUuids` + `uuid('id')->primary()` +
`foreignUuid`), which drives the DTO `id` type (`?string`). The workbench is
the Testbench host that serves the module (panel registration and assets are
Filament concerns — see the `filament` skill). Full detail:
`references/models-and-migrations.md` and `references/workbench.md`.

### Model mechanics (lean models)

Models are data + identity: getters/setters, simple accessors/mutators,
casts, relations — nothing else (Laravel Beyond CRUD, ch04). This is not
the **anemic domain model** anti-pattern: the behavior exists — it lives in
actions, enums, query builders, and collections; the model just stops being
the dumping ground for it.

- **No calculations in accessors.** A computed value (a total, a derived
  status) is calculated by an action and **stored**; reading it is plain
  data. Payoffs: performance (computed once), queryable, no side effects.
  An accessor that loops relations or resolves services (`app(...)`) is a
  user story in disguise — move it to an action.
- **Query scopes → custom query builders.** Scopes are sugar over Eloquent
  builders; named scopes move to a `*QueryBuilder` class wired via
  `newEloquentBuilder()`:

  ```php
  // PostQueryBuilder.php
  final class PostQueryBuilder extends Builder
  {
      public function wherePublished(): self
      {
          return $this->where('status', PostStatus::Published->value);
      }
  }

  // Post.php
  public function newEloquentBuilder($query): PostQueryBuilder
  {
      return new PostQueryBuilder($query);
  }
  ```

- **Collection chains → custom collections.** Repeated collection logic
  moves to a `*Collection` class wired via `newCollection()`; every
  `HasMany` to that model uses it automatically.
- **Embrace the framework:** this replaces the repository pattern — no
  repositories over Eloquent unless a real storage-swap seam exists (the
  lean guardrail).

## Gotchas

- **UI never calls Eloquent directly** — always through an action + DTO (the
  UI→core seam; the rule is in `software-architecture`).
- **Models carry framework traits** (`HasUuids`, `SoftDeletes`, `#[UseFactory]`)
  — Eloquent is persistence + domain model combined; that's accepted.
- **Cross-module deps** go through `Lines\*` namespaces; shared support comes
  from `laravel-module-support`.
- **New modules** start from `laravel-skeleton` / `laravel-package-skeleton`
  (consumed via git remote + rebase).

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-architecture` (the single source of truth for the
  architecture), `filament` (the Filament UI mechanics), `software-testing`
  (the testing contract).
- Reference repos: `~/Development/laravel-skeleton`, `laravel-package-skeleton`,
  `laravel-module-support`, `laravel-module-news`, `laravel-module-user`.
