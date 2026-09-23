# Workbench (the module's host app)

The workbench is the Testbench host that runs the module's Filament panel:

- The panel (`workbench/app/Providers/AdminPanelProvider.php`) registers the
  module's plugin: `->plugin(TodoPlugin::make())`.
- The workbench `User` model needs its own factory
  (`workbench/database/factories/UserFactory.php`) for `User::factory()` to
  work in seeders/tests.
- Before serving the panel, publish Filament's assets:
  `php vendor/bin/testbench filament:assets` (see `new-project`).
