# Delegation brief — <slice / task id>

**Role:** <name; path to its brief under agent-delegation/references/roles/>
**Purpose:** <one sentence>
**Goal & exit criteria:** <what done looks like, measurably>

## Governing skills (by path, from the role → skills matrix)

- `~/.config/opencode/skills/<name>/SKILL.md` — <the rule it binds this task to>
- <one line per governing skill for the role; the worker reads exactly these>
- <if a named skill refers to its own references/, assets/ or scripts/, add that file's absolute path too>

## Environment

- Platform: NixOS; the project devshell is the environment the gates run in.
- Repository / working directory: <absolute path> — confirm with `pwd`, `git remote -v`, `git log`; never assume which repository you are in.
- Devshell: `direnv exec . <cmd>` from the repo root, or `nix develop -c <cmd>`; `nix run` for a one-off tool. Never bypass it with a global binary.
- Gates: <exact commands: typecheck, lint, boundaries, test, build>.
- One session per working directory — do not fight another session over HEAD.

## Read (exhaustive)

- <absolute path> — <why>

## May create / change

- <path or glob>

## Must not touch

- <path or glob>

## Constraints & principles

- <the distilled rule that binds this task>

## Output

- Location: <path>
- Format: <template / shape>

## Stop and ask

- <condition>
- <condition>
