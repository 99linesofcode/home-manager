---
name: filament
description: The user's Filament admin UI mechanics — Resources, Forms, Tables, Plugins, and Pages, and the Filament-to-action seam. The concrete Filament expression of the software-architecture contract, layered on the laravel skill. Use when building, extending, or reviewing Filament resources, forms, tables, plugins, or pages in the user's Laravel modules or applications.
---

# filament

The user's Filament admin UI mechanics. Filament is the admin UI layer of the
user's Laravel modules. It sits in `src/App/Filament/` and is the **UI → Domain
seam**: a Filament page builds a DTO and calls an action; it never touches
Eloquent directly.

The general architecture contract lives in the `software-architecture` skill;
the Laravel mechanics (module structure, actions/DTOs, composer) live in the
`laravel` skill. Load those for the reasoning; this skill is the Filament
mechanics.

## When to use

- Building or extending a Filament resource, form, table, plugin, or page.
- Reviewing Filament code against the user's conventions.
- The user references Filament resources, forms, tables, plugins, or pages.

## The Filament → action seam

The flow for a write operation: **Filament page → `PostData::fromArray(...)` →
`app(CreatePostAction::class)` → Eloquent model**. The page never touches
Eloquent directly; the action is the single seam.

## Module structure (Filament part)

Within a module's `src/App/Filament/`:

```
src/App/Filament/
├── Pages/                # Create*, Edit*, List* (record pages)
├── Plugins/              # *Plugin (registers resource on a Panel)
├── Resources/            # *Resource (Filament resource)
├── Schemas/              # *Form (form schema, static configure())
└── Tables/               # *Table (table schema, static configure())
```

## Naming conventions

| Kind              | Suffix                    | Example               |
| ----------------- | ------------------------- | --------------------- |
| Filament resource | `*Resource`               | `PostResource`        |
| Filament plugin   | `*Plugin`                 | `PostPlugin`          |
| Form schema       | `*Form` (in `Schemas/`)   | `PostForm`            |
| Table schema      | `*Table` (in `Tables/`)   | `PostsTable`          |
| Pages             | `Create*`/`Edit*`/`List*` | `CreatePost`          |

## Resource

A **Resource** delegates to form/table `configure()`, maps pages, and handles
soft-delete route binding. **Filament v5 note:** the form container is
`Filament\Schemas\Schema`, not `Filament\Forms\Form`:

```php
// src/App/Filament/Resources/PostResource.php
class PostResource extends Resource
{
    protected static ?string $model = Post::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-text';

    public static function form(Schema $schema): Schema
    {
        return PostForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return PostsTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListPosts::route('/'),
            'create' => Pages\CreatePost::route('/create'),
            'edit'   => Pages\EditPost::route('/{record}/edit'),
        ];
    }
}
```

## Form / Table schemas

**Form/Table** expose `public static function configure(Schema|Table $schema)`
with private static per-field builder methods (`title()`, `body()`, `status()`).
In v5 the form schema is `Filament\Schemas\Schema` and components are added via
`components()` (not `$form->schema()`):

```php
// src/App/Filament/Schemas/PostForm.php
class PostForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            self::title(),
            self::body(),
            self::status(),
        ]);
    }

    private static function title(): TextInput
    {
        return TextInput::make('title')
            ->required()
            ->maxLength(255);
    }

    private static function status(): Select
    {
        return Select::make('status')
            ->options(PostStatus::class)
            ->required();
    }
}
```

## Plugin

A **Plugin** registers the resource on a panel:

```php
// src/App/Filament/Plugins/PostPlugin.php
class PostPlugin extends Plugin
{
    public function getResources(): array
    {
        return [PostResource::class];
    }
}
```

The host panel registers it: `->plugin(PostPlugin::make())`.

## Pages (the UI → Domain seam)

**Pages** are the seam: `handleRecordCreation` builds
`PostData::fromArray([...$data, 'author_id' => auth()->user()->id])` and calls
`app(CreatePostAction::class)`:

```php
// src/App/Filament/Pages/CreatePost.php
class CreatePost extends CreateRecord
{
    protected static string $resource = PostResource::class;

    protected function handleRecordCreation(array $data): Model
    {
        return app(CreatePostAction::class)(
            PostData::fromArray([...$data, 'author_id' => auth()->user()->id])
        );
    }
}
```

## List pages: the create header action

The List page does **not** auto-add a "New" button in Filament v5 — add it
explicitly via `getHeaderActions()`:

```php
// src/App/Filament/Pages/ListPosts.php
class ListPosts extends ListRecords
{
    protected static string $resource = PostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
```

## Gotchas

- **Pages never call Eloquent directly** — always through an action + DTO.
- **`src/Domain/` must not import Filament/Livewire** — the UI layer is one-way.
- Form/Table schemas are static `configure()` + private per-field builders, not
  inline closures in the resource.
- The action is the single seam; Filament is a delivery mechanism, not a domain
  concern.
- **Date/time pickers render empty values badly in native mode** — use
  `native(false)`.
- **Syncing form fields** (e.g. a computed value, or one field driving another)
  uses `afterStateHydrated` (populate on load) and `afterStateUpdated` +
  `Set`/`Get` (react to change). These are general Filament mechanisms; the
  specific field layout is a per-module decision.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `laravel` (the Laravel mechanics), `software-architecture`
  (the general contract), `software-testing` (the testing contract).
- Wiki concepts: `action-objects.md`, `hexagonal-architecture.md`.
- Reference repos: `~/Development/laravel-module-news`, `laravel-module-user`.
