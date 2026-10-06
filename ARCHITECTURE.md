# ARCHITECTURE.md

The architecture document for this repository, following the
[architecture.md](https://architecture.md) schema — built so an agent (or a
new colleague) can comprehend the codebase from this file alone. This is a
declarative configuration repository, not a service: the "architecture" is the
module graph of a Nix flake and the discipline that keeps it composable. Fill
every section; update it in the same change that alters the architecture it
describes.

## 1. Project Structure

Nix-module-first. Every unit of configuration is one `.nix` file under
`modules/`, auto-imported; every host/user binding is a folder under `hosts/`.
There is no `src/`: the "logic" is the option interface a module exposes and
the `config` block it contributes when enabled.

```
home-manager/
├── flake.nix           # inputs + the HomeConfiguration constructor + outputs
├── flake.lock          # pinned input revisions
├── modules/            # one file per program; auto-imported by default.nix
│   ├── default.nix     # reads its own folder and imports every *.nix
│   ├── <program>.nix   # home.<program>.enable option + config
│   └── <program>/      # a program with sub-concerns (hyprland/, nvim/)
├── hosts/
│   ├── default.nix     # imports shared/ + the selected host
│   ├── shared/         # OS-agnostic baseline (locale, nix, XDG)
│   ├── <hostname>/     # per-host: role/<role>.nix + users/<user>/
│   └── shared/secrets/ # sops-encrypted secrets (never plaintext)
├── overlays/           # nixpkgs overlays (unstable packages)
├── dotfiles/           # raw files a module installs (git ignore, scripts, art)
├── .opencode/          # agent definitions + skills (deployed by modules/opencode.nix)
├── .sops.yaml          # which age keys may encrypt which paths
└── .github/            # changelog + automatic-updates workflows
```

**Where the logic lives.** A module is a Nix module: an `options` block that
declares `home.<name>.enable = mkEnableOption "…"` (plus typed options where
needed), and a `config = mkIf cfg.enable { … }` block that contributes
packages, `programs.*`, `systemd.user.*` units or activation scripts. Host
files only *select*: `hosts/luna/default.nix` imports
`role/<role>.nix` and `users/<user>/` when they exist;
`hosts/shared/default.nix` carries the cross-host baseline. There is no
imperative glue — the module system is the composition engine.

## 2. High-Level System Diagram

```
             flake.nix (HomeConfiguration)
                     │  extraSpecialArgs: hostname, username, role
        ┌────────────┼─────────────────────────────┐
        ▼            ▼                             ▼
   hosts/default.nix  modules/default.nix     overlays/default.nix
   ┌───────────────┐  (readDir → import all)   (unstable + hm-unstable)
   │ shared/       │        │
   │  locale.nix   │        ▼
   │  nix.nix      │   modules/<program>.nix  (home.<x>.enable)
   │ <hostname>/   │        │
   │  role/<role>  │        ▼
   │  users/<user> │   home-manager build
   └───────┬───────┘        │
           │                ▼
           └────────►  home-manager switch --flake .#<host>.<user>
                            │
                            ▼
                  user environment (packages, programs,
                  systemd --user units, XDG config)
                            ▲
                  sops-nix decrypts secrets from
                  hosts/*/secrets/ using the age key at
                  $XDG_CONFIG_HOME/sops/age/keys.txt
```

## 3. Core Components

| Component | Responsibility | Technology | Target |
|---|---|---|---|
| `flake.nix` | Inputs, the `HomeConfiguration` constructor, the `homeConfigurations` outputs (`luna.shorty`, `mars.shorty`) | Nix flakes | any Linux/macOS with Nix |
| `modules/default.nix` | Auto-imports every `.nix` sibling via `builtins.readDir` | Nix module system | build time |
| `modules/<program>.nix` | One program's enable option + config | `mkEnableOption`/`mkIf` | user env |
| `hosts/` | Host/user selection and the OS-agnostic baseline | Nix module system | build time |
| `overlays/default.nix` | Exposes `nix-unstable` and `hm-unstable` package sets | nixpkgs overlay | build time |
| `modules/sops.nix` + `.sops.yaml` | Encrypted secret materialization | sops-nix + age | user env |
| `modules/opencode.nix` | Deploys agents/skills and schedules opencode jobs | opencode + systemd --user timers | user env |
| `modules/obsidian.nix` | Obsidian + the vault: CLI, rclone bisync, the seekstone MCP | Obsidian, rclone, MCP | user env |

### Ports & adapters

This repository is declarative configuration, not a running service, so it owns
no ports. The extension seam is the **module option interface**: a module is
consumed through `home.<name>.enable` (and its typed options), never by
importing its internals. A host that needs a program enables it; it does not
reach into another module's `config`. Cross-cutting behaviour is composed by
the module system, not by a component calling another component directly.

## 4. Data Stores

- **Nix store** (`/nix/store`) — immutable, content-addressed build outputs;
  the repository's only "database". Type: content-addressed store. Purpose:
  every package and generated config file the configuration references.
- **`hosts/*/secrets/`** — sops-encrypted files (age recipients from
  `.sops.yaml`). Purpose: SSH keys, API tokens, `rclone.conf`, dotenv files.
  Decrypted at switch time into `XDG_RUNTIME_DIR/secrets.d` and symlinked
  into place.
- **`flake.lock`** — pinned input revisions (nixpkgs, home-manager, sops-nix,
  stylix, nixvim, …).
- **User state** — XDG dirs (`~/.config`, `~/.local/state`, …) and the
  Obsidian vault at `~/Documents/Obsidian` (kept in sync with Google Drive by
  `rclone bisync`). Not a database.

## 5. External Integrations / APIs

- **GitHub** — flake inputs are GitHub repositories (nixpkgs,
  home-manager, sops-nix, stylix, nixvim, nix-vscode-extensions,
  nixos-vscode-server). Method: Nix flake fetchers; pinned in `flake.lock`.
- **sops / age** — secret decryption. Method: sops-nix; age private key at
  `$XDG_CONFIG_HOME/sops/age/keys.txt`.
- **Google Drive** — the Obsidian vault mirror. Method: `rclone bisync`
  against `gdrive:Obsidian/`, run by a `systemd --user` timer every 5
  minutes (`modules/obsidian.nix`).
- **MCP servers** — `obsidian` (seekstone), `beeper`, `gmail`,
  `google-drive`, `google-calendar`, `discord`, `shopify-dev`, `todoist`.
  Method: opencode MCP integration; remote HTTP or local `npx` (`modules/opencode.nix`, `modules/obsidian.nix`).
- **Cachix / cache.nixos.org** — binary substitutes (trusted public keys in
  `flake.nix`).

## 6. Deployment & Infrastructure

- **No cloud provider, no server.** Deployment is activation on a workstation:
  `home-manager switch --flake .#{homeConfigAttributeName}` (e.g.
  `luna.shorty`), after `direnv`/Nix are available. `home.stateVersion` is
  pinned in `hosts/shared/default.nix`.
- **CI/CD**: GitHub Actions, delegated to the org's reusable workflows —
  `changelog.yaml` (on push to `main`) and `automatic-updates.yaml`
  (Dependabot/agent updates on PRs). There is **no** flake-evaluation CI; the
  build is verified locally by a successful `home-manager switch`.
- **Monitoring/logging**: none. Failures surface as `nix`/`home-manager`
  evaluation errors at switch time; `systemd --user` journals cover the
  timers (rclone, opencode jobs).

## 7. Security Considerations

- **Secrets at rest**: every secret under `hosts/*/secrets/` is sops/age
  encrypted; `.sops.yaml` defines which public keys may encrypt which paths
  (`master` and `luna_shorty` for shared, host and user secret trees).
  Plaintext never enters the repository.
- **Secrets in use**: sops-nix decrypts at activation into
  `XDG_RUNTIME_DIR/secrets.d` (tmpfs) and exposes them via
  `config.sops.secrets.<name>.path`; `EnvironmentFile` references the path
  rather than inlining values.
- **Agent safety**: `modules/opencode.nix` ships a deny-list of destructive
  `bash` commands (privilege escalation, disk/partition destruction,
  pipe-to-shell, nix store/system-config destruction, git history rewrite and
  force-push/force-delete, recursive `rm` on system roots). `todowrite` is
  denied because todos are managed by the wayfinder skill. The allow-list is
  explicit for the safe verbs.
- **Package trust**: `allowUnfree = true`; extra substituters are pinned by
  public key in `flake.nix`.
- **Integrity**: `flake.lock` pins every input; `flake.lock` is intentionally
  git-ignored in consumer repos via git-skeleton's `.ignore` (the devshell
  case), but here it is tracked at the root.

## 8. Development & Testing Environment

- **Local setup**: Nix with flakes enabled. There is no devshell for this
  repo; edit modules/hosts and apply. `nix fmt` formats with `nixfmt` (the
  flake's `formatter` output).
- **Testing**: there is no unit-test suite. The verification is the build
  itself — a clean `home-manager switch --flake .#luna.shorty` (or
  `nix flake check` for evaluation) is the gate. This is deliberate: a Nix
  configuration's behaviour is its evaluation.
- **Code quality**: `nixfmt` via the flake formatter; `nix flake check` for
  evaluation errors.
- **Mechanical gates and what they make impossible**:
  - The **module system** rejects unknown options (`home.<x>.enable` must be
    declared by a module that is imported) — a typo'd or undeclared option
    cannot silently do nothing.
  - `modules/default.nix`'s `readDir` import means a module file that exists
    is loaded — no forgotten import.
  - **sops-nix** refuses to activate without the age key, so an unencrypted
    or mis-keyed secret fails the switch rather than leaking.
  - The **opencode permission deny-list** makes the listed destructive
    commands impossible for the agent.

## 9. Future Considerations / Roadmap

**Known debt / open items** (from `README.md`'s "Work In Progress"):

- Some programs may not yet be bundled with the right module; the README
  invites issues for rough edges.
- `flake.nix` carries a TODO for dedicated SSH keys and a server role for
  `mars` (`role = "server"`); the server configuration is not yet complete.
- `modules/obsidian.nix` carries a TODO: `nodejs_22` is added manually so
  `npx` works (for the seekstone MCP) — decide whether to install it
  globally or run `npx` from the store.

**Deliberate non-goals:**

- **No `flake-utils`.** The README states the choice explicitly: stay close
  to the Nix language rather than adopt a helper library.
- **No NixOS system configuration.** This repo is home-manager only, so it
  works on any Linux (and macOS) regardless of the OS; system-level config
  lives elsewhere.
- **No second dotfile manager.** Nix modules and `home.file` are the only
  mechanism; there is no chezmoi/stow layer.
- **No custom packaging of tools that upstream already provides.** Prefer
  the ecosystem's module or `pkgs` entry over a hand-rolled derivation.

## 10. Project Identification

Project Name: home-manager

Repository URL: https://github.com/99linesofcode/home-manager

Primary Contact/Team: Jordy Schreuders (99linesofcode)

Date of Last Update: 2026-10-06

## 11. Glossary / Acronyms

- **Flake** — a Nix project with a pinned `flake.lock` and an `outputs`
  function; the unit of reproducible configuration.
- **`HomeConfiguration`** — the constructor in `flake.nix` that builds one
  home-manager configuration from the hosts and modules.
- **Home configuration attribute** — the output name, `<host>.<user>` (e.g.
  `luna.shorty`), passed to `home-manager switch --flake .#…`.
- **Host / role / user** — `hosts/<hostname>/` with an optional
  `role/<role>.nix` and `users/<username>/`; the `extraSpecialArgs`
  (`hostname`, `username`, `role`) select them.
- **Module** — a Nix file declaring `options` and `config`; one per program.
- **`mkEnableOption` / `mkIf`** — the enable-flag idiom every program module
  follows.
- **sops-nix / age** — the secret-management integration and its encryption
  scheme; the private key lives outside the repo.
- **XDG** — the freedesktop base-directory spec (`~/.config`,
  `XDG_RUNTIME_DIR`); the repo enables it via `xdg.enable`.
- **Devshell** — a `nix develop` environment; other repos pull
  `devshell-node`/`devshell-php` as submodules.
- **Substituter** — a binary cache; pinned by public key in `flake.nix`.

## 12. Conventions & Boundaries

The enforced conventions of this repository — the gates, naming and
documentation surfaces that keep it composable.

- **Folder structure**: `modules/` holds one file per program (or one folder
  per program with sub-concerns, e.g. `modules/hyprland/`,
  `modules/nvim/`); `hosts/` holds `shared/` plus one folder per hostname;
  `overlays/` holds nixpkgs overlays; `dotfiles/` holds raw files modules
  install. The path locates the unit; the file name locates the program.
- **Module shape**: every program module declares
  `home.<name>.enable = mkEnableOption "<description>"` and contributes its
  configuration under `config = mkIf cfg.enable { … }`. Typed options use
  `mkOption { type = …; }`. No module reads another module's internals.
- **Auto-import**: `modules/default.nix` imports every sibling `.nix` via
  `builtins.readDir`; adding a module file is the whole registration step.
  Host import logic uses the `if-exists`/`existing-imports` pattern
  (`hosts/default.nix`, `hosts/luna/default.nix`) so optional
  `role/`/`users/` files are picked up without failing when absent.
- **Host layout**: `hosts/<hostname>/` owns `role/<role>.nix` and
  `users/<username>/`; `hosts/shared/` owns the OS-agnostic baseline
  (`locale.nix`, `nix.nix`) and the `home.stateVersion` pin.
- **Secrets**: only under paths configured in `.sops.yaml`
  (`hosts/shared/secrets/`, `hosts/<host>/secrets/`,
  `hosts/<host>/users/<user>/secrets/`); reference them through
  `config.sops.secrets.<name>.path`, never inline a plaintext value.
- **Formatting**: `nixfmt` via `nix fmt` (the flake `formatter` output).
  `.editorconfig` governs non-Nix files.
- **Style**: prefer the Nix module system and upstream `pkgs`/modules over
  custom derivations; stay close to plain Nix (no `flake-utils`).
- **Documentation surfaces**: the module `options` descriptions are the
  per-module documentation; `README.md` carries the usage narrative and the
  Work-In-Progress list; a change that alters how a host is built updates
  this file in the same change.
