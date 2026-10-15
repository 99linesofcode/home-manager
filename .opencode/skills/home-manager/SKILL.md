---
name: home-manager
description: Change and verify the user's declarative NixOS/home-manager configuration — the flake at ~/Development/home-manager. Use when adding or editing a module under modules/, enabling it on a host, changing a host's packages or options, or checking that a config change evaluates and renders without running home-manager switch.
metadata:
  category: tooling
  route-when: "Use when changing the user's declarative NixOS/home-manager configuration — adding or editing a module under modules/, changing a host's options or packages, or verifying that a change evaluates and renders."
  route-not-when: "Use `customize-opencode` for opencode's own config surface rather than the config layer itself."
---

# home-manager

The contract for changing this machine's declarative configuration. The repo is
`~/Development/home-manager` — a Nix flake whose `homeConfigurations` are the
source of truth for the user's environment. This skill governs the config layer;
`customize-opencode` governs the opencode surface that one module of it renders.

## Related

- **Loads:** (none — an entry point)
- **References:** `customize-opencode`, `git-workflow`.

## External

| Path | Load | Read when |
|---|---|---|
| `~/Development/home-manager/` | required | always — the config repo this skill governs |

## One concern per module

A module is `modules/<name>.nix`, auto-imported by `modules/default.nix` (a
`readDir` over the directory) — a new file needs no registration. It exposes
`home.<name>.enable` and, under `mkIf cfg.enable`, owns both the app
(`home.packages`) and its integration:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.freecad;
in
with lib;
{
  options = {
    home.freecad.enable = mkEnableOption "freecad";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        freecad
      ];
    };

    programs = {
      mcp = {
        enable = true;
        servers = {
          freecad = {
            type = "local";
            command = lib.getExe' pkgs.uv "uvx";
            args = [
              "freecad-mcp"
            ];
          };
        };
      };
    };
  };
}
```

`modules/obsidian.nix` and `modules/freecad.nix` are the worked examples.

## Hosts enable; modules implement

A host lives at `hosts/<host>/users/<user>/default.nix`. It turns a module on
with `<name>.enable = true;`, kept alphabetical among its siblings. Never list an
app in a host's `home.packages` when a module owns it — the module is the single
home for the concern.

## Verify by evaluating — never by switching

The agent cannot run `home-manager switch` (denied), and must not try. Prove a
change by evaluating it, from the repo root, against the config name in
`flake.nix` (`packages.<system>.homeConfigurations."<host>.<user>"`):

- **An option is set** —
  `nix eval --json '.#packages.x86_64-linux.homeConfigurations."luna.shorty".config.<option>'`.
- **A generated file renders correctly** — build the `xdg.configFile` source and
  read it:
  `nix build --no-link --print-out-paths '.#packages.x86_64-linux.homeConfigurations."luna.shorty".config.xdg.configFile."<path>".source'`.
- **Formatting** — `nixfmt` is the flake's formatter:
  `nix run nixpkgs#nixfmt -- --check <file>`.

## A flake sees only tracked files

`nix eval`, `nix build`, and `home-manager switch` read the git tree, not the
working directory. A newly created file must be `git add`ed before any gate sees
it — otherwise the change evaluates as if it were not there.

## Land it

Author the change on a worktree branch (see `git-workflow`). The user is the
merge point: they merge, run `home-manager switch`, and restart whatever it
serves. A running opencode keeps the already-loaded config until restarted.
