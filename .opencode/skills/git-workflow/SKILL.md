---
name: git-workflow
description: Git and GitHub workflow for this user's projects. GitHub Flow by default, always checking CONTRIBUTING.md first; Conventional Commits; ask before commit/push/PR; safe git operations (no force-push, no history rewriting). Also encodes the development discipline: incremental atomic changes, cleanup-as-you-go (no dangling code), and history hygiene (squash by feature before push). Use when the user asks to commit, branch, merge, push, pull, open or review a pull request, file or triage a GitHub issue, create a release, or when starting work in a repo and the workflow needs to be determined.
---

# git-workflow

The user's Git + GitHub operating procedure. Encodes the workflow decision
(which methodology a repo uses), the mechanics (local git + GitHub via MCP/gh),
the commit style, the autonomy level, and the safety rules.

## When to use

- Any git operation: init, clone, branch, commit, merge, rebase, push, pull,
  stash, log, diff, reset, cherry-pick, tag
- Any GitHub operation: issues, pull requests, reviews, releases, branches,
  files, code search
- Starting work in a repo where the workflow needs to be determined
- Authoring or updating a `CONTRIBUTING.md`
- Scaffolding a new repo from the user's skeleton/boilerplate ecosystem

## Core principles

1. **The repo's conventions win.** Always check `CONTRIBUTING.md` first (and
   the existing branch structure + git log style). Follow what the repo says.
2. **GitHub Flow is the default** when a repo has no conventions: `main` is
   always deployable, every change enters via a short-lived branch + PR.
3. **Ask before commit/push/PR.** Prepare everything, show the plan/diff, and
   act only on explicit go-ahead. (The user's permission config is permissive,
   but the *workflow* is ask-first.)
4. **Conventional Commits** for messages.
5. **Never rewrite shared history.** No force-push, no `-D` branch deletion,
   no filter-branch/filter-repo. These are also hard-denied in the user's
   opencode permission config — the skill and the guardrails agree.
6. **Never commit secrets.** Scan staged content for keys/tokens before
   committing.

## Step 0: Determine the repo's workflow

Before any git work in a repo, determine the methodology:

1. Read `CONTRIBUTING.md` (repo root). If present, it defines the workflow —
   follow it exactly (branching, PR requirements, commit style, review rules).
2. If absent, inspect the repo's actual state:
   - `git branch -a` — long-lived branches? `develop`? `release/*`?
   - `git log --oneline -15` — commit message style, merge vs. rebase history
   - GitHub: protected branches? PRs required? (via MCP or `gh`)
3. If the repo clearly follows a methodology (Git Flow, GitLab Flow, etc.),
   follow it.
4. Otherwise apply **GitHub Flow** (below).
5. If the repo is the user's own and has no `CONTRIBUTING.md`, offer to author
   one together (see "Authoring CONTRIBUTING.md") so the flow is explicit.

## GitHub Flow (default)

- `main` is always deployable.
- Every change gets a short-lived branch off `main`:
  `feat/<slug>`, `fix/<slug>`, `chore/<slug>`, `docs/<slug>`
- Work happens on the branch; commit early and often with Conventional
  Commits.
- Open a PR when the branch is ready (or early as a draft for visibility).
- The PR is the integration point: review + CI checks.
- Merge back to `main` (squash or merge — match repo history), delete the
  branch.
- No feature flags needed — unfinished work simply stays on the branch.

### Branch naming

`<type>/<short-slug>` where type matches the Conventional Commit type:
`feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/`.

### PR lifecycle

1. Push the branch.
2. Open the PR (MCP or `gh pr create`) with a Conventional-Commits-style
   title and a body that says what and why.
3. Reference any related issue (`Fixes #N` to auto-close).
4. Request review if the repo expects it; run CI.
5. Merge when green + approved (or per repo rules).
6. Delete the branch locally + remotely.

## Development discipline: incremental, atomic, self-cleaning

The user's standard for how code changes are made and committed. The goal: no
dangling code, no messy history, no "cleanup later" debt. Cleanup is part of
the work, not a follow-up task.

### Work incrementally and atomically

- **One concern per change.** A change is a single coherent unit: one feature,
  one fix, one refactor. If a task spans multiple concerns, split it into
  sequential commits — never one commit that mixes them.
- **Verify as you go.** After each change, run the project's checks
  (typecheck, tests, build) before moving on. A change that doesn't verify is
  not done.
- **Commit early, commit often.** A verified unit of work gets committed
  immediately. Don't accumulate uncommitted work across multiple concerns.

### Clean up as you go (the anti-dangling rule)

When a change supersedes or invalidates existing code, remove the dead code
**in the same change** — not later:

- **Removed a call site?** Delete the now-unused function, type, import, or
  parameter in the same commit.
- **Changed a design direction?** Delete the code the old direction left
  behind (dead branches, unused helpers, superseded modules) in the same
  commit.
- **Changed a contract?** Update callers, docs, and config in the same commit.
- **After each change, grep for dangling references** to anything you renamed
  or removed: `grep -rn "<removed-symbol>" src/`. A symbol with no callers is
  dead — remove it or justify keeping it.

The test: **after every commit, the tree should contain no code that isn't
reachable from a live entry point, and no docs that describe behavior that
doesn't exist.**

### Verify the whole before committing

Before committing a change:

1. Run the project's checks (typecheck, tests, build, lint).
2. Grep for dangling references to renamed/removed symbols.
3. Review the diff — does it contain only this change's concern?
4. Update docs (README, comments) that the change affects, in the same commit.

### History hygiene (before push)

History is rewritten **only before push** (never after). When a feature
spanned multiple commits, squash them into one coherent commit per feature
before pushing:

- **Squash by feature.** A feature's debugging journey (fix → fix → fix)
  collapses into one `feat:` commit. The history tells the story of *where it
  landed*, not the journey.
- **Reword for clarity.** The message states the final state, not the
  intermediate steps: "feat: transcribe voice notes locally (ffmpeg +
  voxtype, incl. encrypted mxc://)" — not "add transcribe, fix ffmpeg, fix
  voxtype".
- **Verify the squashed tree.** After squashing, `git diff <squashed> <pre-squash-tip>`
  must be empty — the tree is identical, only the history changed.
- **Safe rebase mechanics:** use `git rebase -i` with a sequence editor
  (`GIT_SEQUENCE_EDITOR`) and a message editor (`GIT_EDITOR`) for
  non-interactive squash/reword. On NixOS, scripts need `#!/usr/bin/env bash`
  (no `/bin/bash`). Abort and reset cleanly if a rebase goes sideways —
  reflog preserves the pre-rebase tip.

### The user's definition of done

A change is done when:

- [ ] It works (verified by running it)
- [ ] It's atomic (one concern, one commit)
- [ ] It's clean (no dead code, no dangling references, docs updated)
- [ ] It's committed with a clear Conventional Commit message
- [ ] History is squashed by feature before push (if it spanned multiple
      commits)

## Conventional Commits

Format: `<type>(<scope>): <description>`

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`,
  `ci`, `chore`, `revert`
- Scope optional: `feat(offertes): add PDF export`
- Imperative, lowercase, ≤ ~72 chars: "add", "fix", not "added"/"fixes"
- Breaking changes: `feat!: ...` or a `BREAKING CHANGE:` footer
- Body: what + why, not how. Bullet points for multiple concerns.
- Match the repo's existing style if it differs (Step 0).

## Local git operations

### Before committing (always)

- `git status` — what's changed
- `git diff` (and `git diff --staged`) — review the actual changes
- `git log --oneline -10` — match the repo's commit style
- Stage only intended files: `git add <paths>` — never `git add -A` blindly
- Scan for secrets in the staged diff before committing

### Commit

- `git commit -m "<type>(<scope>): <description>"` (+ `-m` for body lines)
- Never amend a pushed commit (rewrites shared history)

### Branching & merging

- `git switch -c <type>/<slug>` to create
- `git switch main && git pull` before branching (stay current)
- Merge via PR (GitHub Flow). For local-only merges, prefer `--no-ff` when
  the repo history uses merge commits, `--ff-only` when it's linear.

### Rebase

- Rebase your *own* unpushed branch onto `main` to stay current:
  `git rebase main` (or `git pull --rebase`)
- Never rebase shared/pushed branches.

### History hygiene

- `git log --oneline --graph` to inspect
- `git reset --soft HEAD~1` to fix your last *unpushed* commit
- Never: `filter-branch`, `filter-repo`, `push --force`, `branch -D`,
  `push --delete`

## GitHub operations (MCP + gh)

Prefer the GitHub MCP for structured operations; use `gh` for anything the
MCP doesn't cover or where a CLI is more natural.

- **Issues:** read scoped (one issue + its bounded comments), create/update
  with clear titles + bodies, triage with labels. Issues may seed Wayfinder
  planning sessions.
- **PRs:** create, review (approve/request changes/comment), merge, update
  branch. Inspect status, diff, files, commits, check runs before acting.
- **Releases:** list, create, get by tag. Tag + release notes from
  Conventional Commit history.
- **Repos/branches/files:** create repos, branches, push files, search code.
- Always return PR/issue URLs when you create them.

## Safety rules (never do these)

- `git push --force` / `-f` (force-with-lease only, and only with explicit
  user approval)
- `git branch -D` (force delete) — use `-d` (safe form)
- `git push --delete <branch>` / `git push origin :<branch>`
- `filter-branch`, `filter-repo`, `git rebase` on shared branches
- Amending or rewriting any commit that has been pushed
- Committing secrets, `.env` files, keys, tokens (scan first)
- `git add -A` / `git add .` without reviewing what it stages

These match the user's opencode permission deny-list (decisions.md): the
config blocks force-push, force branch deletion, and history rewriting at the
shell level too.

## Authoring CONTRIBUTING.md

For the user's own repos, offer to define the workflow together and encode it
in a `CONTRIBUTING.md`:

1. Propose a methodology for the project's size (GitHub Flow for most;
   Git Flow only for versioned release trains; GitLab Flow for environment
   staging).
2. Agree on: branching model, PR requirements, commit style, review rules,
   CI expectations.
3. Write `CONTRIBUTING.md` at the repo root, concise and concrete.
4. The skill then reads it back on the next session (Step 0) — the file
   becomes the source of truth.

## Scaffolding a new repo (the user's skeleton ecosystem)

The user has a **seed → sapling** skeleton ecosystem. Start from the right
skeleton and wire it up following the user's conventions.

### The skeleton ecosystem

| Repo | Role |
|---|---|
| `git-skeleton` | Universal base: `.editorconfig`, `.prettierrc`, `.gitignore`, `.ignore` (config flows via remote + rebase) |
| `.github` | Shared org files: `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `dependabot.yaml`, 6 workflows (README/LICENSE render natively in repos lacking their own) |
| `.github-php` | PHP/Laravel GitHub skeleton: thin workflow wrappers (`uses: 99linesofcode/.github/...@main`), `devshell-php` submodule |
| `devshell-php` / `devshell-rust` | Nix dev environments (`flake.nix`) |
| `laravel-package-skeleton` | Laravel module seed: composer.json, `src/` (App/Domain/Infra), database/, tests/, workbench/, `devshell-php` submodule |

### Choosing the right skeleton

| Project type | Start from | Wire in |
|---|---|---|
| Generic repo | `git-skeleton` | — |
| Laravel module | `laravel-package-skeleton` | `.github-php` workflows + `devshell-php` submodule |
| PHP app | `git-skeleton` + `.github-php` | `devshell-php` submodule |
| Rust app | `git-skeleton` + `devshell-rust` | `devshell-rust` submodule |

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
git remote add git-skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch git-skeleton
git rebase git-skeleton/main
```

- **Override is expected.** When you've locally modified a shared file (e.g.
  `.gitignore`) and rebase, you'll get a merge conflict. **Resolve it** — you
  want the new upstream change AND your override. This is intended.
- Pull updates later: `git fetch git-skeleton && git rebase git-skeleton/main`.

### Wiring the devshell (submodule)

```bash
git submodule add git@github.com:99linesofcode/devshell-php.git devshell
```

Standalone, pinned. Update with `git submodule update --remote`.

### Wiring shared config files (remote + rebase)

Config flows from `git-skeleton` via remote + rebase (NOT subtree — root-level
config can't be subtreed, see above):

```bash
git remote add git-skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch git-skeleton
git rebase git-skeleton/main
```

**Adopting an existing repo** (one that predates the remote + rebase model and
has no shared history with git-skeleton): use a one-time adoption merge instead
of a rebase, so history isn't rewritten:

```bash
git remote add git-skeleton git@github.com:99linesofcode/git-skeleton.git
git fetch git-skeleton
git merge git-skeleton/main --allow-unrelated-histories
```

Resolve the merge keeping the repo's own README/LICENSE and repo-specific
config overrides; take git-skeleton's config where the repo is missing it.
From then on, updates flow via `git fetch git-skeleton && git rebase
git-skeleton/main` (or `git merge git-skeleton/main` for repos that prefer
merge history).

### Wiring the GitHub workflows (thin-wrapper delegation)

For a **project** consuming `.github-php`, copy the thin-wrapper `.yaml` files
into the project's `.github/workflows/`:

```bash
mkdir -p .github/workflows
cp ~/Development/.github-php/workflows/*.yaml .github/workflows/
```

The wrappers `uses: 99linesofcode/.github/.github/workflows/<name>.yaml@main`,
so GitHub resolves the latest generic logic at runtime — no sync step. **This
is delegation, not subtree** — deliberate: a subtree would inline the workflow
content (stale until `subtree pull`), while delegation always runs the latest.

### Scaffolding a Laravel module

1. Start from `laravel-package-skeleton` (remote + rebase, as above).
2. Wire the `devshell-php` submodule (already in the skeleton's `.gitmodules`).
3. Copy the `.github-php` workflows.
4. Rename the namespace: `Lines\Skeleton\` → `Lines\<Module>\` in
   `composer.json` (see the `laravel-architecture` skill).

## Wayfinder integration

Wayfinder is the planning model; this skill is the delivery mechanics.

- Wayfinder's map lives in `planning/<slug>/map.md`; GitHub is a destination.
- When Wayfinder resolves a ticket into an Issue/PR, use this skill's
  procedures to execute the delivery.
- Mid-flight decision tickets never mirror into GitHub — only resolved
  deliverables do.

## Edge cases & gotchas

- **Repo with no CONTRIBUTING.md and mixed history:** ask the user which
  model to apply rather than guessing.
- **Draft PRs:** open as draft when the branch is WIP but visibility helps.
- **CI failing on the PR:** fix on the branch, push again; never merge red.
- **Merge conflicts:** resolve on the branch, prefer the smaller diff; ask
  the user when a conflict needs a judgment call.
- **Large repos / monorepos:** scope commits to the relevant area; don't stage
  unrelated files.
- **`gh` not authenticated:** check `gh auth status`; the GitHub MCP is the
  fallback.