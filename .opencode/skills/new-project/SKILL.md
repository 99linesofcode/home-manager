---
name: new-project
description: Set up a new software development project from scratch — a new git repository, a Laravel application or module, and the supporting packages. Use when the user wants to start a new project, scaffold a new repo, create a new Laravel app or module, or set up a fresh development environment. Orchestrates git-workflow (git mechanics) and laravel (Laravel specifics).
---

# new-project

The end-to-end procedure for starting a new software development project — any
language or framework. It orchestrates the git mechanics (from `git-workflow`)
and the language/environment-specific wiring. The setup is the same shape for
every project; only the skeleton, devshell, and workflows differ by language.

## MANDATORY gate — read before any scaffold

This skill is the **only sanctioned path** to a new repository — for you or
for a worker you dispatch. Never compose a scaffold from memory; work from
this skill's steps. If you are about to create a repo (or write a worker
package that creates one) and have not loaded this skill, **stop and load it
now**.

Non-negotiables whatever the project type:

- The **devshell submodule** is wired for every language project. Never
  install language tooling ad-hoc on the host — NixOS rejects ad-hoc
  dynamically-linked binaries; the devshell exists so you never fight that.
- The **package manager follows the skeleton default** (pnpm for node),
  overridden only when the runtime itself is that tool (bun-runtime → bun).
- Worker packages for scaffolds **instruct the worker to load and follow
  this skill** — a summarized-from-memory procedure is a defect.

## When to use

- Starting a new project from scratch (unknown what will be built yet).
- Creating a new git repository.
- Creating a new Laravel application or module.
- Setting up a fresh development environment (packages).

## The skeleton ecosystem

The user's repos follow a naming pattern: a **universal base** plus
**per-language layers**. The pattern generalizes — new languages add a
`devshell-<lang>`, a `.github-<lang>`, and optionally a `<framework>-skeleton`
without changing the procedure.

| Layer | Pattern | Mechanism | Role |
|---|---|---|---|
| Base | `git-skeleton` | remote + rebase | universal config for every repo |
| Devshell | `devshell-<lang>` | submodule | Nix dev environment for that language |
| Workflows | `.github-<lang>` | thin-wrapper delegation | GitHub Actions for that language |
| Starter | `<framework>-skeleton` | remote + rebase | project seed for a specific framework |

**How the workflows fit together.** The shared workflow *logic* lives in the
`.github` org repo (`.github/workflows/*.yaml`). Each language has a wrapper
repo (`.github-php`, future `.github-rust`, ...) holding the thin-wrapper
`.yaml` files that `uses: 99linesofcode/.github/.github/workflows/<name>.yaml@main`.
The framework skeletons (`laravel-skeleton`, `laravel-package-skeleton`) ship
these thin wrappers in their own `.github/workflows/`, so scaffolding from a
skeleton brings them along — no separate copy step. You only pull from the
language wrapper (`.github-php`) when the base skeleton doesn't ship them (e.g.
a generic PHP app started from `git-skeleton`).

Known skeletons (the pattern generalizes; add new ones as they appear):

| Repo | Role | Used for |
|---|---|---|
| `git-skeleton` | universal base | every repo |
| `devshell-php` | Nix dev env | all PHP projects |
| `devshell-rust` | Nix dev env | all Rust projects |
| `.github-php` | PHP workflow wrapper | PHP/Laravel projects |
| `laravel-skeleton` | app starter | Laravel applications |
| `laravel-package-skeleton` | module starter | Laravel modules |
| `node-skeleton` | base | Node.js projects |
| `rails-skeleton` | starter | Rails projects |

**Not skeletons:** `kubernetes-fleet` (a fleet config) doesn't seed new
projects.

## Step 0: Decide what you're building

Before scaffolding, determine the project type (ask the user if unclear). This
picks the base skeleton, devshell, and workflows:

- **Generic repo** — `git-skeleton` only.
- **Laravel application** — `laravel-skeleton` + `devshell-php` + `.github-php`.
- **Laravel module** — `laravel-package-skeleton` + `devshell-php` + `.github-php`.
- **PHP app** — `git-skeleton` + `devshell-php` + `.github-php`.
- **Rust app** — `git-skeleton` + `devshell-rust`.
- **Node package** — `node-skeleton`.

## Step 1: Create the project directory + init git

```bash
mkdir "$HOME/Development/<name>"
cd "$HOME/Development/<name>"
git init -b main
```

## Step 2: Add the base skeleton as a remote

The base is `git-skeleton` for generic repos, or the framework starter (e.g.
`laravel-package-skeleton`) for framework projects. Wire it via remote + rebase:

```bash
git remote add origin <REPOSITORY>
git remote add skeleton git@github.com:99linesofcode/<base-skeleton>.git
git fetch skeleton
git reset --hard skeleton/main   # empty repo (no base commit) — see git-workflow
```

- **Empty repo gotcha:** `git rebase` fails on a fresh repo with no base commit.
  Use `git reset --hard skeleton/main` instead. Rebase is only for adopting an
  existing repo that already has history. (Full detail in `git-workflow`.)
- **Override is expected.** When you locally modify a shared file and rebase
  later, you'll get a merge conflict — resolve it, you want both the upstream
  change and your override.

## Step 3: Wire the language/environment layers

Follow the mechanism rules from `git-workflow`:

| Layer | Mechanism |
|---|---|
| Devshell (`devshell-<lang>`) | **submodule** |
| Workflows | **skeleton ships them** (thin-wrapper delegation); pull from `.github-<lang>` only if the base skeleton doesn't ship them |
| Community files (`.github` repo) | **subtree** |

The framework skeletons ship the thin-wrapper workflows in their own
`.github/workflows/`, so they come along with the scaffold. For a generic
language repo (base `git-skeleton`), copy the wrappers from the language
wrapper repo (`.github-<lang>`).

**Which wrappers:** for a **module**, `automatic-updates.yaml` and
`changelog.yaml` only. There is no `test.yaml` — the user has not defined a
GitHub Action for running the test suite automatically (tests run locally via
`composer test`). `deploy.yaml` is for deployable applications, not modules.

The exact commands are in `git-workflow` ("Wiring the devshell", "Wiring shared
config files", "Wiring the GitHub workflows").

## Step 4: Create the GitHub repo + labels

```bash
gh repo create 99linesofcode/<name> --public --description "<desc>"
```

Then apply the canonical Shape Up labels in a single swipe (delete the default
GitHub labels, create the canonical set):

```bash
REPO=<name>

for l in accessibility bug documentation duplicate enhancement "good first issue" \
         "help wanted" invalid question wontfix; do
  gh label delete "$l" --repo "$REPO" --yes 2>/dev/null
done

while IFS='|' read -r name color desc; do
  gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" --force
done <<'EOF'
type: slice|c3b1e1|The big picture, sliced
type: pitch|f2d5b3|Shaped and ready to bet
type: task|b9e0c4|The doing
type: bug|f0b6b6|Something broken
type: chore|b8d0e8|The little stuff
EOF
```

Keep `dependencies` and `github_actions` (added by Dependabot/Actions).

Then set the Actions workflow permissions so the automatic-updates workflow can
approve and merge Dependabot PRs:

```bash
gh api -X PUT repos/99linesofcode/<name>/actions/permissions \
  -f enabled=true \
  -f default_workflow_permissions=write \
  -f can_approve_pull_request_reviews=true
```

- `default_workflow_permissions=write` — read/write for the `GITHUB_TOKEN`.
- `can_approve_pull_request_reviews=true` — lets the token approve PRs (the
  automatic-updates workflow runs `gh pr review --approve`).

**Permissions principle.** The caller (thin wrapper) declares the `GITHUB_TOKEN`
ceiling; called (reusable) workflows inherit it and can only downgrade, never
elevate. So thin-wrapper workflows declare the permissions they need
(`automatic-updates` → `pull-requests: write, contents: write`; `changelog` →
`contents: write`), and shared reusable workflows declare nothing unless they
downgrade.

## Step 5: Optionally create a Shape Up project

Not every repo warrants a dedicated project — only client engagements and
products with real scope (not skeletons or utility repos). If it does, copy the
template project (#9, titled `.github`) and link it:

```bash
new=$(gh project copy 9 --source-owner 99linesofcode --target-owner 99linesofcode \
  --title "<repo> project" --format json -q '.number')
gh project link "$new" --owner 99linesofcode --repo "<repo>"
```

The template carries the Stage, Work type, Appetite, Hill, Start, End fields.

## Step 6: Load the devshell + install packages

The devshell is a Nix dev environment loaded through direnv. After wiring the
devshell submodule, allow direnv to load it, then install dependencies:

```bash
direnv allow
pnpm install    # frontend deps (if any)
composer install  # PHP deps (if any)
composer dev    # start the dev environment (or use the devshell)
```

- `direnv allow` — loads the Nix devshell (run once after scaffolding; re-run
  when the flake changes).
- **Filament modules:** publish Filament's compiled assets before serving the
  panel — `php vendor/bin/testbench filament:assets` (copies Filament's JS/CSS
  into `public/`). Without it the admin panel renders unstyled. Also run
  `pnpm run dev` (Vite) for the module's own frontend assets.

## Step 7: Initial commit + push

```bash
git add .
git commit -m "chore: scaffold <name> from <base-skeleton>"
git push -u origin main
```

- Follow the `git-workflow` skill for commit style (Conventional Commits) and
  push behavior (ask before push).

## Scripts

The identical setup is scripted; environment-specific scripts live here in the
skill (they're only relevant when scaffolding).

- `scripts/scaffold.sh <name> [base-skeleton]` — the generic steps (1, 2, 4):
  create dir, init git, add the base skeleton remote, reset, create the GitHub
  repo, apply labels. `base-skeleton` defaults to `git-skeleton`.
- `scripts/scaffold-<lang>.sh <name>` — the environment-specific steps (3, 6):
  wire the devshell submodule, copy the workflows, install. One per language.

## Related

- **Loads:** `git-workflow` (scaffolding mechanics), `software-architecture`
  (the architecture contract).
- **References:** `laravel` (Laravel conventions), `shape-up` (labels + project
  template), `github` (platform interface).
- Wiki: [[modular-monolith]], [[hexagonal-architecture]], [[action-objects]].
