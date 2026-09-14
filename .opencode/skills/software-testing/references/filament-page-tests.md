# Filament page tests

Filament page flows are tested with `livewire(...)`. Set the current panel in a
`beforeEach`, authenticate with `actingAs`, then drive the page:

```php
<?php

declare(strict_types=1);

use Filament\Facades\Filament;
use Lines\Auth\Database\Factories\UserFactory;
use Lines\Todo\App\Filament\Pages\CreateTodo;
use Lines\Todo\Domain\Models\Todo;

use function Pest\Laravel\actingAs;
use function Pest\Laravel\assertDatabaseHas;
use function Pest\Livewire\livewire;

describe('TodoResource', function () {
    beforeEach(function () {
        Filament::setCurrentPanel(Filament::getPanel('admin'));
        actingAs(UserFactory::new()->create());
    });

    it('creates a Todo', function () {
        $todo = Todo::factory()->make()->except('id');

        livewire(CreateTodo::class)
            ->fillForm($todo)
            ->call('create')
            ->assertHasNoFormErrors()
            ->assertRedirect();

        assertDatabaseHas(Todo::class, $todo);
    });
});
```

- `Filament::setCurrentPanel(...)` is required in every Filament test.
- `actingAs(UserFactory::new()->create())` authenticates the panel user.
- `fillForm($array)` + `call('create')` drives the create flow.
