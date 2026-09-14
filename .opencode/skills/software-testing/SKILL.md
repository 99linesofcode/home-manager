---
name: software-testing
description: The user's testing contract — BDD (or at least TDD), Given/When/Then scenarios, and what must be tested and when. Language-agnostic with Pest as the reference implementation. Use when writing, extending, or reviewing tests, or when deciding what to test and how to structure a test suite.
---

# software-testing

The user's standard for how software is tested. The contract: **BDD, or at
least TDD**, expressed as **Given/When/Then** scenarios. Tests are written
before or alongside the code they verify, and they describe behavior, not
implementation.

The concrete reference implementation is **Pest** (PHP/Laravel), which the
user's modules use with the Given/When/Then syntax. The contract is
language-agnostic; Pest is the expression.

## When to use

- Writing, extending, or reviewing tests.
- Deciding what to test and when a test is warranted.
- The user references BDD, TDD, Given/When/Then, Pest, or test structure.

## Core principles

1. **TDD is a hard requirement.** The order is always: **spec → tests → code**,
   one use case at a time (one task at a time in Shape Up). Write the failing
   test first (red), make it pass (green), then refactor. Never write the
   implementation before its test. This is not optional — it is how all
   software work is done.
2. **BDD frames the test as a behavior scenario.** Every test reads as a
   scenario: the setup (Given), the action (When), the assertion (Then).
3. **Test behavior, not implementation.** Assert on outcomes and state, not on
   how the code got there. A test that pins internal calls is a liability.
4. **One behavior per test.** A test verifies one thing. If a scenario has
   multiple assertions, they should all support one behavior.
5. **Tests are part of the change.** A change isn't done until its tests pass
   (see `software-development`). Tests ship in the same change as the code.

## What must be tested (the contract)

Test the behavior that matters, and skip the ceremony:

- **Use cases / actions** — each action's behavior: what it creates, updates,
  or transitions, and its side effects. Assert on the resulting state
  (e.g. `assertDatabaseHas`).
- **DTO casting / computed fields** — how input is coerced and derived.
- **State transitions** — enum state machines: valid transitions succeed,
  invalid ones throw.
- **Validation rules** — form/request validation: valid input passes, invalid
  input is rejected.
- **UI flows** — page render + create/edit flows (e.g. via `livewire(...)`).

Skip what doesn't earn its keep (the lean guardrail):

- **Trivial getters/setters** — no behavior to protect.
- **Framework mechanics** — the framework already tests itself.
- **Implementation details** — don't test how, test what.

## Given/When/Then structure

Structure each test as a scenario. In Pest, use `describe` for the subject and
`it` for the behavior. The Given/When/Then is **implicit in the body order** —
setup, then act, then assert — not spelled out with comments.

**Only tests that touch the database** (actions that write, model queries)
start with `uses(\<Module>\Tests\TestCase::class);` so they get the Testbench
TestCase (RefreshDatabase + WithWorkbench) even in `Unit/`. Pure classes —
DTOs, enums, stateless logic — don't need it; they run on the plain Pest
TestCase:

```php
<?php

declare(strict_types=1);

uses(\Lines\News\Tests\TestCase::class);   // only when the test needs the DB

use Lines\News\Domain\Actions\CreatePostAction;
use Lines\News\Domain\DataTransferObjects\PostData;
use Lines\News\Domain\Models\Post;

use function Pest\Laravel\assertDatabaseHas;

describe('CreatePostAction', function () {
    it('creates a post', function () {
        // Given — build the input
        $post = Post::factory()->make()->except('id');

        // When — perform the action
        (new CreatePostAction)(PostData::fromArray($post));

        // Then — assert the outcome
        assertDatabaseHas(Post::class, $post);
    });
});
```

- **Given** — set up the input and preconditions (often a factory `make()`).
- **When** — perform the action (invoke the action directly: `(new Action)(...)`).
- **Then** — assert the outcome (`assertDatabaseHas`, `expect(...)`).

Use nested `describe` blocks for states and methods (e.g.
`describe('fromArray', ...)` → `describe('status', ...)` → `it('casts ...')`).

## Test layout mirrors source

The test tree mirrors the source tree, so a test is easy to find:

```
tests/
├── Unit/Domain/...    # mirrors src/Domain
├── Feature/App/...    # mirrors src/App
└── Browser/
```

## Fixtures

Use factories with **fluent states** that name the scenario:

```php
Post::factory()->draft()->create();
Post::factory()->published()->create();
```

A fluent state encodes the Given, so the test body stays focused on the
behavior.

## Filament page tests (Feature)

Filament page flows are tested with `livewire(...)`. Set the current panel in a
`beforeEach`, authenticate with `actingAs`, then drive the page
(`fillForm` + `call('create')` + `assertHasNoFormErrors` + `assertRedirect`).
Full example: `references/filament-page-tests.md`.

## TDD loop (per use case / task)

Work one use case at a time (one task at a time in Shape Up). The **spec is the
slice or task definition** — the shaped work item that already states the
behavior. For each:

1. **Spec** — the slice/task definition is the spec; it states the behavior in
   one sentence (which becomes the `it('...')` description).
2. **Write the failing test** that describes the behavior (red).
3. **Write the minimum code** to make it pass (green).
4. **Refactor**, keeping the test green.
5. Commit the code and its tests together (see `software-development`).

Never write the implementation before its test. If you catch yourself
implementing first, stop and write the test for the behavior you just built.

## Gotchas

- **Don't test implementation.** Assert on state and outcomes, not on which
  internal methods were called.
- **Don't over-mock.** Mock the ports/adapters at the boundary, not the domain
  logic you're testing.
- **Keep tests fast.** A slow suite stops being run. Prefer in-memory/fake
  infrastructure over real external services.
- **One behavior per test.** A failing test should point at one thing.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-development` (the discipline: tests ship with the
  change), `laravel` (Pest + Testbench mechanics), `software-architecture`
  (what the layers are).
- Wiki concepts: `action-objects.md` (what actions are tested).
