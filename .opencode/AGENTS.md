# AGENTS — vault schema & agent operating contract

Co-evolved interface between you (human) and agents. Agents read and conform,
and may *suggest* changes but never apply them unilaterally.

## Root

The AI subsystem is rooted at `~/Documents/Obsidian/AI/`. Every path below is
relative to that root, **except the capture inbox**: the Obsidian vault is
`~/Documents/Obsidian/`, and its `Inbox/` is the **vault-root**
`~/Documents/Obsidian/Inbox/` — never `AI/Inbox/`. All other agent-managed
content lives under the `AI/` subdirectory.

## Environment

The machine's declarative configuration lives in the home-manager repo at
`~/Development/home-manager/` — the source of truth for opencode, the nix
environment, and this vault's tooling. The concrete paths:

- **Skills:** `~/Development/home-manager/.opencode/skills/<name>/SKILL.md`
- **Agents:** `~/Development/home-manager/.opencode/agents/`
- **Config (permissions, scheduled jobs, MCP):** `~/Development/home-manager/modules/opencode.nix`

Paths under `~/.config/opencode/` are read-only nix-store symlinks: edit the
source in the repo, then run `home-manager switch`. Generated copies must
never be edited directly — the sandbox denies them, correctly.

## Operating contract

All operational procedure lives in skills. `vault-notes` is **always loaded**
— every session, in full — because it is the contract that keeps notes filed
correctly. The rest are loaded on demand; load the relevant skill before
acting:

| Operation | Skill |
|---|---|
| Vault changes (notes, entities, projects, meetings) | `vault-notes` *(always loaded)* |
| Wiki maintenance (ingest, query, lint) + OKF format | `wiki` |
| Memory (working, episodic, semantic, reflection) | `memory` |
| Spec-driven delivery (seed → discovery → spec → architecture → slices) | `project-seed`, `discovery-interview`, `feature-spec`, `architecture-and-skeleton`, `slice-delivery`, `spec-change` |
| Dispatch a worker | `agent-delegation` |
| Git/GitHub delivery | `git-workflow` |

## Permissions

Paths are relative to `~/Documents/Obsidian/AI/`, except `Inbox/`, which is the
vault root's inbox (`~/Documents/Obsidian/Inbox/`).

| Path | Owner | Agents may |
|---|---|---|
| `Inbox/` (vault root) | human + agent | process + discard original; never edit in place |
| `wiki/` | agent | write |
| `memory/` | agent | write |
| `planning/` | agent | write — transient scratchpad; trashed when the effort completes |
| `logs/` | agent | write — transient; cleaned up on completion |
| `AGENTS.md` | human | read only |

## Hard rules

1. Treat `Inbox/` contents as immutable source material — process + discard
   original, never edit in place.
2. Never rewrite `log.md` history; append only.
3. Never apply changes to `AGENTS.md` yourself; propose them.
4. `HOT.md` is rolling, not archival; prune below cap.
5. Todoist is never written automatically (manual sync).
6. Every knowledge concept carries a non-empty `type` (OKF §4.1).
