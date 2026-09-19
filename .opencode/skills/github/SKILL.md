---
name: github
description: The user's GitHub platform interface — reading issues, joining discussions, sending updates, and creating pull requests linked to issues. The GitHub API/platform layer, distinct from git-workflow (local git mechanics). Optional: used by the orchestrator or a worker when work needs to flow through GitHub. Use when reading or triaging issues, participating in discussions, posting updates, or creating PRs that reference issues.
---

# github

The user's GitHub **platform interface**: the operations that flow work through
GitHub. This is distinct from `git-workflow`, which covers local git mechanics
(branching, commits, squash, safety). This skill covers the GitHub API/platform
layer — issues, discussions, PRs, and updates.

This skill is **optional**: it's loaded when the orchestrator or a worker needs
to interface with GitHub. It pairs with `git-workflow` for the local mechanics
and with `wayfinder` for how resolved tickets become GitHub deliverables.

## When to use

- Reading or triaging GitHub issues.
- Joining or participating in GitHub discussions.
- Sending updates on issues or PRs.
- Creating pull requests and linking them to the appropriate issues.
- The user references GitHub issues, discussions, PRs, or updates.

## Core operations

### Read issues

- Read an issue **scoped**: that issue + its bounded comments + the relevant
  files. Never pull unrelated repo state into context.
- An issue may seed a Wayfinder planning session (see `wayfinder`).
- Triage with the canonical labels (`type: slice/pitch/task/bug/chore`).

### Join discussions

- Read the discussion thread before contributing.
- Post a substantive update or answer; don't add noise.
- Reference the relevant issue/PR where it helps.

### Send updates

- Post status updates on issues and PRs: what's done, what's next, what's
  blocked.
- Link related issues/PRs so the thread tells a coherent story.

### Create pull requests (linked to issues)

- Create the PR with a Conventional-Commits-style title and a body that says
  what and why.
- Reference the issue it resolves (`Fixes #N` to auto-close).
- Link the PR to the appropriate issue(s).
- Return the PR URL when you create it.

## Workflow

1. **Read scoped** — the issue, its bounded comments, the relevant files.
2. **Plan** — if the work is large, run it through `wayfinder`; the issue is a
   seed, not a plan.
3. **Execute** — do the work following `software-development` and
   `git-workflow` (branch, commit, squash).
4. **Deliver** — push, open the PR, link it to the issue, post an update.
5. **Report** — return the PR/issue URLs.

## Relationship to other skills

- `git-workflow` — local git mechanics (branching, commits, squash, safety).
  Load it when executing the delivery.
- `wayfinder` — the planning model; GitHub is a destination. Resolved tickets
  emit to GitHub as issues/PRs; mid-flight decision tickets never mirror.
- `code-review` — the review contract applied to the PR before merge.

## Related

- **Loads:** (none — optional, loaded on demand)
- **References:** `git-workflow` (local mechanics), `wayfinder` (planning),
  `code-review` (review contract).
