---
name: new-project
description: Set up a new software development project from scratch — a new git repository, a Laravel application or module, and the supporting packages and Docker container. Use when the user wants to start a new project, scaffold a new repo, create a new Laravel app or module, or set up a fresh development environment. Orchestrates git-workflow (git mechanics) and laravel-architecture (Laravel specifics).
---

# new-project

The end-to-end procedure for starting a new software development project. It
orchestrates the git mechanics (from `git-workflow`), the Laravel specifics
(from `laravel-architecture`), and the supporting setup (packages, Docker).

## When to use

- Starting a new project from scratch (unknown what will be built yet).
- Creating a new git repository.
- Creating a new Laravel application or module.
- Setting up a fresh development environment (packages, Docker).

## The two Laravel paths

There are **two** distinct ways to start a Laravel project, depending on what
you're building:

| You're building | Start with | Skeleton via |
|---|---|---|
| A **Laravel application** (a deployable app) | `laravel-skeleton` | remote + rebase (default) |
| A **Laravel module** (a reusable Composer package) | `laravel-package-skeleton` | remote + rebase |

**The rsync route is the exception, not the rule.** You only use
`laravel new` + `rsync` when:
- You want a **Laravel version the skeleton doesn't support yet**, or
- You're doing a **greenfield experiment** — quickly spin up an app, play with
  it, tag on changes, discard it later.

Generally, **`laravel-skeleton` is the project starter** for Laravel
applications. Use it via remote + rebase (no rsync).

The rest of this skill covers both.

## Step 0: Decide what you're building

Before scaffolding, determine the project type (ask the user if unclear):

- **Generic repo** — no framework, just git + config.
- **Laravel application** — a deployable app (client project, internal tool).
- **Laravel module** — a reusable Composer package (news, user, billing).
- **PHP app** — a PHP application that isn't a full Laravel module.
- **Rust app** — a Rust application.

## Step 1: Create the GitHub repository

1. Create the repo on GitHub (via MCP or `gh repo create`).
2. Add the `CONTAINER_REGISTRY_PASSWORD` as a repository secret.
3. Set **Settings > Actions > General > Workflow permissions** to
   `Read and write`.
4. Check **Allow GitHub Actions to create and approve pull requests**.

## Step 2: Scaffold the git repository

### Generic repo (remote + rebase)

```bash
git init
git remote add origin <REPOSITORY>
git remote add git-skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch git-skeleton
git rebase git-skeleton/main
```

- **Override is expected.** When you've locally modified a shared file (e.g.
  `.gitignore`) and rebase, you'll get a merge conflict. **Resolve it** — you
  want the new upstream change AND your override. This is intended.
- Pull updates later: `git fetch git-skeleton && git rebase git-skeleton/main`.

### Laravel application (laravel-skeleton, remote + rebase) — DEFAULT

```bash
git init
git remote add origin <REPOSITORY>
git remote add laravel-skeleton git@github.com:99linesofcode/laravel-skeleton.git
git fetch laravel-skeleton
git rebase laravel-skeleton/main
```

- **`laravel-skeleton` is the project starter** for Laravel applications. It
  provides the full app structure (composer.json, `src/`, database/, tests/,
  workbench/) plus the shared config.
- Pull updates later: `git fetch laravel-skeleton && git rebase laravel-skeleton/main`.

#### Exception: `laravel new` + rsync (unsupported version / greenfield)

Only use this when you want a **Laravel version the skeleton doesn't support
yet**, or a **greenfield experiment** you'll play with and discard:

```bash
laravel new laravel-starter
mkdir project-starter
cd project-starter
git init
git remote add skeleton git@github.com:99linesofcode/laravel-skeleton.git
git fetch skeleton
git rebase skeleton/main

rsync -av laravel-starter/ .
git add . && git commit -m "initial commit"
```

- `laravel new` generates the full app; `rsync` overlays the skeleton's config
  files (`.editorconfig`, `.prettierrc`, `.gitignore`, etc.) onto it.
- The skeleton is added as a **remote** (not the origin) so you can pull
  updates, but the app's own files come from `laravel new`.

### Laravel module (remote + rebase)

```bash
git init
git remote add origin <REPOSITORY>
git remote add laravel-package-skeleton git@github.com:99linesofcode/laravel-package-skeleton.git
git fetch laravel-package-skeleton
git rebase laravel-package-skeleton/main
```

Then rename the namespace: `Lines\Skeleton\` → `Lines\<Module>\` in
`composer.json` (see the `laravel-architecture` skill).

## Step 3: Wire the shared layers

Follow the mechanism rules from `git-workflow`:

| Layer | Mechanism |
|---|---|
| Devshell | **submodule** |
| Shared config files | **subtree** |
| GitHub workflows | **thin-wrapper delegation** (copy the wrappers) |

### Devshell (submodule)

```bash
git submodule add git@github.com:99linesofcode/devshell-php.git devshell
```

### GitHub workflows (thin-wrapper delegation)

```bash
mkdir -p .github/workflows
cp ~/Development/.github-php/workflows/*.yaml .github/workflows/
```

The wrappers `uses: 99linesofcode/.github/.github/workflows/<name>.yaml@main`,
so GitHub resolves the latest generic logic at runtime.

### Shared config files (subtree)

```bash
git subtree add --prefix=. git@github.com:99linesofcode/git-skeleton.git main --squash
```

## Step 4: Install packages

```bash
pnpm install
composer install
composer dev
```

- `pnpm install` — frontend dependencies.
- `composer install` — PHP dependencies.
- `composer dev` — start the dev environment (or use the devshell).

## Step 5: Add the Docker container

```bash
git submodule add https://github.com/99linesofcode/docker-php.git docker
cp docker/docker-compose.yaml.dist ./docker-compose.yaml
```

- The Docker container is a **submodule** (standalone, pinned).
- `docker-compose.yaml.dist` is copied to `docker-compose.yaml` (the local
  override).

## Step 6: Initial commit + push

```bash
git add .
git commit -m "initial commit"
git push -u origin main
```

- Follow the `git-workflow` skill for commit style (Conventional Commits) and
  push behavior (ask before push).

## Related

- `git-workflow` — the git mechanics (branching, commits, PRs, scaffolding
  mechanisms).
- `laravel-architecture` — the Laravel conventions (layering, action objects,
  modules).
- Wiki: [[modular-monolith]], [[hexagonal-architecture]], [[action-objects]].