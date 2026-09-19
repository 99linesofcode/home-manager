---
name: git-workflow
description: Git and GitHub workflow for this user's projects. GitHub Flow by default, always checking CONTRIBUTING.md first; Conventional Commits (including commit message wording); ask before commit/push/PR; safe git operations (no force-push, no history rewriting). Includes collapsing commits (fixup + squash by feature before push), rebasing, and stashing. The broader development discipline (incremental atomic changes, cleanup-as-you-go) lives in the software-development skill. Use when the user asks to commit, branch, merge, rebase, stash, push, pull, open or review a pull request, file or triage a GitHub issue, create a release, author a CONTRIBUTING.md, or when starting work in a repo and the workflow needs to be determined.
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

- **Never work on `main`.** Create the branch *before* making any change, and
  do all work there. `main` is only ever touched by a merge. If you're about to
  edit files while on `main`, stop and branch first. This is a hard rule, not a
  preference — working on `main` is a workflow violation.
- `main` is always deployable.
- Every change gets a short-lived branch off `main`:
  `feat/<slug>`, `fix/<slug>`, `chore/<slug>`, `docs/<slug>`
- Work happens on the branch; commit early and often with Conventional
  Commits.
- Open a PR when the branch is ready (or early as a draft for visibility).
- The PR is the integration point: review + CI checks.
- Merge back to `main` via **squash** — one commit per change/use case on
  `main` (the change chain's atomic-commit rule). Delete the branch after
  merge.
- Exception: a repo's **initial scaffold** may push directly to `main`
  (`new-project` step 7). Everything after goes through a branch + PR.
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

## Collapsing commits (fixup + squash)

The user works with many small commits — including `fixup!` commits during
development — and collapses them into a clean history before push. History is
rewritten **only before push** (never after).

### The workflow

1. **Commit freely during development.** Small commits, `fixup! <subject>`
   commits, whatever keeps the work moving. `git commit --fixup=<sha>` or
   `git commit --fixup=HEAD` for the last commit.
2. **Before push, collapse by feature.** A feature's debugging journey
   (feat → fix → fix → fixup) collapses into one coherent commit per feature.
   The history tells the story of *where it landed*, not the journey.
3. **Reword for clarity.** The message states the final state, not the
   intermediate steps: "feat: transcribe voice notes locally (ffmpeg +
   voxtype, incl. encrypted mxc://)" — not "add transcribe, fix ffmpeg, fix
   voxtype".

### Autosquash (the fast path for fixup commits)

If you've been using `git commit --fixup=<sha>`, `--autosquash` does the
arrangement for you — it moves each `fixup!`/`squash!` commit onto its target
automatically:

```bash
git rebase -i --autosquash <base>
```

The todo list comes pre-arranged with the fixups marked `fixup` next to their
targets. Just review and save.

### Manual squash (interactive rebase)

```bash
git rebase -i <base>
```

In the todo list, change `pick` to `squash` for the commits to fold into the
one above them. The squash target keeps its message; the squashed commits'
messages are combined — edit to the final message.

### Non-interactive (scripted) rebase

For automation or when the editor is awkward:

- `GIT_SEQUENCE_EDITOR` rewrites the todo list (e.g. `sed` to change `pick`
  to `squash`/`reword` for specific SHAs).
- `GIT_EDITOR` supplies the commit message for each reword/squash.
- **NixOS gotcha:** scripts need `#!/usr/bin/env bash` — there is no
  `/bin/bash`.
- **Reword one commit at a time.** Batch-reword in a single rebase can create
  duplicate commits when SHAs shift mid-rebase. Do one `reword` per rebase
  run, verify, then the next.

### Verify the collapsed tree

After squashing, the tree must be identical to the pre-squash tip:

```bash
git diff <squashed-tip> <pre-squash-tip>   # must be empty
```

Only the history changed, never the content.

### Recovery if a rebase goes sideways

- `git rebase --abort` to bail out cleanly.
- If a `git reset` lands wrong, the reflog preserves the pre-rebase tip:
  `git reflog` → find the old tip → `git reset --hard <sha>`.
- `git rebase --continue` after resolving conflicts.

## Conventional Commits

Format: `<type>(<scope>): <description>` — types: `feat`, `fix`, `docs`,
`style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Scope
optional. Breaking changes: `feat!: ...` or a `BREAKING CHANGE:` footer.

**The description (~80 chars baseline) tells the user what they can now do.**
Accessible, plain language, no jargon — understandable to non-native
speakers without being pedantic or plebeian. Write it for the person using
the feature, not the person who wrote it: "sync GitHub task changes into
vault notes", not "add fetchChangedTasks to ProjectManagementPort".

**The body introduces the developer to the change**: what it does and why,
with the how in enough detail to orient before reading the code. A few short
lines beat one dense paragraph.

Match the repo's existing style if it differs (Step 0).

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
- Merge via PR (GitHub Flow). For local-only merges, prefer `--ff-only` —
  the user dislikes merge commits. `--no-ff` only when the repo history
  clearly uses merge commits.

### Rebase

- Rebase your *own* unpushed branch onto `main` to stay current:
  `git rebase main` (or `git pull --rebase`)
- **Branch updates are rebase, never merge.** Bringing an in-flight branch
  up to date (from `main` or its upstream) goes through rebase — no merge
  commits. Stash dirty files first, rebase, then pop:

  ```bash
  git stash && git rebase main && git stash pop
  ```

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
- `git reset --hard` when there are uncommitted changes — it silently discards
  them. Commit or `git stash` first. Branches share a working tree, so a
  `reset --hard` on one branch destroys uncommitted work on every branch.

These match the user's opencode permission deny-list (decisions.md): the
config blocks force-push, force branch deletion, and history rewriting at the
shell level too.

## CONTRIBUTING.md (extend, don't fork)

The org-wide source of truth is the shared `CONTRIBUTING.md` in the
`.github` repo — GitHub renders it in every repo that lacks its own. Repos
do NOT get their own file unless their flow genuinely diverges.

- **Step 0 resolution order:** the repo's own `CONTRIBUTING.md` → the
  `.github` fallback → the default (GitHub Flow).
- If the shared file is missing or stale, **fix it there** — one edit
  teaches every repository at once (2026-09-18: it was missing entirely,
  which is how a scaffold bypassed the branch+PR flow unnoticed).
- Author a per-repo `CONTRIBUTING.md` only for a genuine override (e.g. a
  different merge style), and say why at the top.

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
| `laravel-package-skeleton` | Laravel module seed: composer.json, `src/` (App/Domain/Infra), database/, tests/, workbench/, `devshell-php` submodule |
| `node-skeleton` | Node package starter (private) |
| `rails-skeleton` | Rails starter (private) |
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

Standalone, pinned. Update with `git submodule update --remote`.

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
## Related

- **Loads:** (none — loaded on demand)
- **References:** `software-development` (the change chain and definition of
  done that govern commits), `new-project` (the scaffolding procedure this
  skill's mechanics serve), `github` (the platform layer for issues/PRs).
