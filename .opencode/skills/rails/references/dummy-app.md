# Dummy app (the engine's host app)

`spec/dummy` is the engine's own host app — the analog of Laravel's Testbench
workbench:

- It mounts the engine, so its routes, helpers, and migrations load in
  isolation.
- Its tables are the engine's, prefixed by `isolate_namespace`.
- The engine's specs run against it, so the module is testable without the real
  host.
