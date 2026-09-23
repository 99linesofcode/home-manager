---
name: systemd-scheduler
description: Scheduled opencode jobs are declarative home-manager config — the home.opencode.scheduledJobs option renders systemd user service+timer pairs via mkScheduledJob. Use when asked to schedule a recurring agent job, add/remove/change a scheduled job, or inspect why a scheduled run behaved a certain way.
license: MIT
compatibility: opencode
---

# Systemd scheduler (declarative)

Scheduled jobs live in `modules/opencode.nix` in the home-manager repo
(`~/Development/home-manager`). There are no hand-rolled unit files and no
registry — the Nix config is the source of truth, the systemd journal is the
run log.

## How it works

- `home.opencode.scheduledJobs` is a list of `{ skill, schedule ? "*-*-01
  12:00", model ? "openrouter/z-ai/glm-5.3-flash" }`.
- `mkScheduledJob` (same file, `let` block) renders each entry into
  `systemd.user.services."opencode-<skill>"` + `.timers."opencode-<skill>"`:
  oneshot, WorkingDirectory = vault AI dir (so the vault's AGENTS.md contract
  auto-loads), sops `EnvironmentFile` (OPENROUTER_API_KEY), DBUS session bus
  env (notify-send works), Restart=on-failure 5min (3 per 60min),
  Persistent=true timers.
- ExecStart runs headless: `opencode run --model <model> "Execute the
  attached skill instructions fully." --file <flake-source>/.opencode/
  skills/<skill>/SKILL.md` — the skill is attached from the flake source, so
  skill content is versioned atomically with the config generation.

## Adding a job

1. Write the skill: `.opencode/skills/<name>/SKILL.md` (frontmatter: name,
   description, license, compatibility). Headless prompts must be fully
   self-contained; avoid negated "do not execute" phrasing (produces empty
   completions on orchestrator+deepseek).
2. **`git add` the skill directory in the same change.** Flake sources
   exclude untracked files even in dirty trees — the build does not validate
   the `--file` path, only runtime fails.
3. Add an attrset to `scheduledJobs` (module default, or a host config —
   note a host assignment replaces the default list).
4. `home-manager switch` (user runs it). Verify:
   `systemctl --user list-timers 'opencode-*'`.

## Operating

- Force a run: `systemctl --user start opencode-<skill>.service`
- Logs: `journalctl --user -u opencode-<skill>.service`
- Change cadence: edit the entry's `schedule` (OnCalendar syntax — see
  wiki/concepts/systemd-timers.md), switch.
- Remove: delete the attrset (+ the skill if unused), switch.

## Unit-file gotchas

Recorded in wiki/concepts/systemd-timers.md: systemd expands `%` specifiers
in Exec lines (`%s` = shell path) and consumes `\"` escapes — anything
non-trivial belongs in the Nix-generated command or a script file, never
inline `sh -c` with nested quoting.

## Related

- **beeper-bridge** skill — for injecting prompts into the *live* session
  (chat bridging); scheduled jobs are always fresh headless sessions.
