# The skeleton ecosystem

## Scaffolding a new repo (the user's skeleton ecosystem)

The user has a **seed → sapling** skeleton ecosystem. Start from the right
skeleton and wire it up following the user's conventions.

### The skeleton ecosystem

| Repo | Role |
|---|---|
| `git-skeleton` | Universal base: `.editorconfig`, `.prettierrc`, `.gitignore`, `.ignore` (config flows via remote + rebase) |
| `.github` | Shared org files: `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `dependabot.yaml`, 6 workflows (README/LICENSE render natively in repos lacking their own) |
| `.github-php` | PHP/Laravel workflow wrapper: thin workflow wrappers (`uses: 99linesofcode/.github/...@main`), `devshell-php` submodule |
| `.github-js` | Node/pnpm workflow wrapper: thin workflow wrappers, `devshell-node` submodule |
| `devshell-php` / `devshell-rust` / `devshell-node` | Nix dev environments (`flake.nix`) |
| `laravel-skeleton` | Laravel application starter (composer.json, `src/`, database/, tests/, workbench/) |
| `laravel-package-skeleton` | Laravel module seed: composer.json, `src/` (UI/core/infrastructure), database/, tests/, workbench/, `devshell-php` submodule |
| `node-skeleton` | Node package starter (private) |
| `rails-skeleton` | Rails starter (private) |
| `rails-package-skeleton` | Rails module seed: engine gem, `app/` interior, `spec/dummy`, `package.yml`, devshell |
| `kubernetes-base` / `kubernetes-php` | Kubernetes manifests / Helm charts |

**Not skeletons:** `kubernetes-fleet` (a fleet config) is NOT a skeleton
repository — it doesn't seed new projects.

### Choosing the right skeleton

| Project type | Start from | Wire in |
|---|---|---|
| Generic repo | `git-skeleton` | — |
| Laravel application | `laravel-skeleton` | `.github-php` workflows + `devshell-php` submodule |
| Laravel module | `laravel-package-skeleton` | `.github-php` workflows + `devshell-php` submodule |
| PHP app | `git-skeleton` + `.github-php` | `devshell-php` submodule |
| Rust app | `git-skeleton` + `devshell-rust` | `devshell-rust` submodule |
| Node package | `node-skeleton` | `.github-js` workflows + `devshell-node` submodule |
| Rails app | `rails-skeleton` | — |
| Rails module | `rails-package-skeleton` | `.github` workflows + devshell |

### The three mechanisms (pull + override)

| Mechanism | Use for |
|---|---|
| **remote + rebase** | The **base skeleton** you build on and rarely override (conflicts on rebase are the point — they surface override-vs-upstream decisions) |
| **submodule** | **Standalone** self-contained deps (devshell) — pinned, isolated |
| **subtree** | **Shared code that must live inside the repo** (community files in `.github/`) — updates flow, you own + override |

**Rule of thumb:** standalone → submodule; shared/must-live-in-repo → subtree;
base → remote + rebase.

**Config files (`.editorconfig`, `.prettierrc`, `.gitignore`) are remote +
rebase, NOT subtree.** Verified 2026-09-06: `git subtree add --prefix=.` fails
with `fatal: prefix '.' already exists` — git refuses the repo root as a
subtree prefix. Root-level config can't be subtreed. The user's skeleton
ecosystem uses remote + rebase for config: `git-skeleton` is the base remote,
each repo pulls it and overrides freely.

**README/LICENSE are never synced.** GitHub natively renders the `.github`
repo's README/LICENSE in any repo lacking its own — the fallback is
server-side, no git mechanism involved. Repos keep their own README/LICENSE
and diverge.

### ⚠️ GitHub caveat (submodule → subtree)

**GitHub does not traverse submodules.** If shared files must be *available to
GitHub* (workflows, community files), a submodule won't work — the files won't
be there when GitHub runs. **Substitute a subtree for the submodule.** This is
the `.github-php` scenario: it pulls in the shared `.github` repo, so `.github`
community files (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY) should be a
**subtree**, not copied manually:

```bash
git subtree add --prefix=.github git@github.com:99linesofcode/.github.git main --squash
```

Subtree inlines the files AND records the upstream link (`git-subtree-dir:`
annotation), so `git subtree pull` later gets updates. Manual copy loses the
link. Detect existing subtrees via `git log --grep="git-subtree-dir"` (no
central registry like `.gitmodules`).

**Workflows are thin-wrapper delegation, not subtree.** The `.github-php`
workflows `uses: 99linesofcode/.github/.github/workflows/<name>.yaml@main` —
GitHub resolves the latest generic logic at runtime. This is deliberate:
delegation always runs the latest, while a subtree would inline stale content
until `subtree pull`.

### Scaffolding a generic repo (remote + rebase)

```bash
git init
git remote add origin <REPOSITORY>
git remote add skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch skeleton
git rebase skeleton/main
```

- **Empty repo gotcha:** `git rebase` fails on a fresh repo with no base commit
  (`fatal: Could not resolve HEAD to a commit`). For a brand-new empty repo,
  use `git reset --hard <skeleton>/main` instead of rebase — it sets `main` to
  the skeleton's tip directly. Rebase is only for adopting an existing repo
  that already has history.
- **Override is expected.** When you've locally modified a shared file (e.g.
  `.gitignore`) and rebase, you'll get a merge conflict. **Resolve it** — you
  want the new upstream change AND your override. This is intended.
- Pull updates later: `git fetch skeleton && git rebase skeleton/main`.

### Wiring the devshell (submodule)

```bash
git submodule add git@github.com:99linesofcode/devshell-php.git devshell
```

Standalone, pinned. `git submodule add` clones the submodule, so a fresh
scaffold is initialized; a repo **adopted or cloned without
`--recurse-submodules`** is not — run `git submodule update --init` and confirm
`git submodule status` shows no leading `-` (a `-` means declared-but-empty;
`.github` and `.github-php` were found that way on 2026-10-09). Update a pinned
submodule with `git submodule update --remote`.

Every devshell ships `actionlint` and `shellcheck`, so workflow YAML and the
shell inside `run:` blocks lint locally.

### Wiring shared config files (remote + rebase)

Config flows from `git-skeleton` via remote + rebase (NOT subtree — root-level
config can't be subtreed, see above):

```bash
git remote add skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch skeleton
git rebase skeleton/main
```

**Adopting an existing repo** (one that predates the remote + rebase model and
has no shared history with git-skeleton): use a one-time adoption merge instead
of a rebase, so history isn't rewritten:

```bash
git remote add skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch skeleton
git merge skeleton/main --allow-unrelated-histories
```

Resolve the merge keeping the repo's own README/LICENSE and repo-specific
config overrides; take git-skeleton's config where the repo is missing it.
From then on, updates flow via `git fetch skeleton && git rebase
skeleton/main` (or `git merge skeleton/main` for repos that prefer
merge history).

### Wiring the GitHub workflows (thin-wrapper delegation)

The framework skeletons (`laravel-skeleton`, `laravel-package-skeleton`) ship
the thin-wrapper workflows in their own `.github/workflows/`, so they come
along with the scaffold — no copy step. For a generic language repo (base
`git-skeleton`), copy the wrappers from the language wrapper repo
(`.github-php` for PHP, `.github-js` for Node):

```bash
mkdir -p .github/workflows
cp ~/Development/.github-php/workflows/*.yaml .github/workflows/   # PHP
cp ~/Development/.github-js/workflows/*.yaml .github/workflows/    # Node
```

The wrappers `uses: 99linesofcode/.github/.github/workflows/<name>.yaml@main`,
so GitHub resolves the latest generic logic at runtime — no sync step. **This
is delegation, not subtree** — deliberate: a subtree would inline the workflow
content (stale until `subtree pull`), while delegation always runs the latest.

**Why copy, not subtree:** the thin-wrapper files must physically exist in the
repo for GitHub to trigger them, and git subtree operates on whole repos, not
subdirectories — subtree-ing `.github-php` would drag in `.editorconfig`,
`.envrc`, `.gitignore`, and the `devshell` submodule, none of which belong in a
consuming project. The wrappers are tiny and stable, so the copy is effectively
one-time, not a recurring sync.

### Scaffolding a Laravel module

1. Start from `laravel-package-skeleton` (remote + rebase, as above).
2. Wire the `devshell-php` submodule (already in the skeleton's `.gitmodules`).
3. Copy the `.github-php` workflows.
4. Rename the namespace: `Lines\Skeleton\` → `Lines\<Module>\` in
   `composer.json` (see the `laravel` skill).
