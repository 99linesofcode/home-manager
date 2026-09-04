---
name: systemd-scheduler
description: Create, update, or remove a systemd user timer and service pair that runs an opencode agent on a schedule — either as a fresh headless session or injected into the currently active session through the opencode Unix socket plugin. The agent, model, skills, and prompt are all configurable per job. Use when asked to run something periodically, on a schedule, every N minutes/hours, or at a specific time.
license: MIT
compatibility: opencode
---

# Systemd Scheduler

Create, update, or remove a systemd user timer and service pair that runs an
opencode agent on a schedule. Two modes:

- **fresh** (default): each run is a new headless session (`opencode run`) with
  its own context — its own prompt, agent, model, and skills.
- **attach**: each run injects the prompt into the currently active session
  through the opencode Unix socket plugin (`curl --unix-socket <socket> ...`),
  so the job talks to the live session and its context. This is how you build
  bridges — e.g. watch a Beeper chat and forward messages into your live
  session.

## What I do

When asked to schedule a task, run something periodically, or set up a
recurring agent job, I will:

1. Gather the required parameters from the user
2. Write a systemd user service unit that runs opencode headlessly
3. Write a systemd user timer unit that triggers the service
4. Register the job in the scheduler registry
5. Enable and start the timer

When asked to list, update, or remove a scheduled job, I manage the
registry and units accordingly.

## Parameters

Collect these from the user before proceeding. Use sensible defaults
where marked.

| Parameter     | Required | Default              | Description                                      |
|---------------|----------|----------------------|--------------------------------------------------|
| `name`        | yes      | —                    | Short slug, e.g. `check-beeper`. Used as unit name. |
| `schedule`    | yes      | —                    | Systemd OnCalendar expression, e.g. `hourly`, `*:0/15`, `Mon..Fri 09:00` |
| `prompt`      | yes      | —                    | The prompt injected into the agent each run      |
| `mode`        | no       | `fresh`              | `fresh` = new headless session; `attach` = inject into the active session via the Unix socket plugin |
| `socket`      | attach   | —                    | Path to the opencode Unix socket, e.g. `/run/user/1000/opencode.sock`. Required when `mode=attach`. |
| `session`     | no       | active session       | Session ID to inject into (attach mode). Omit to target the active session. |
| `agent`       | no       | opencode default     | Named agent defined in opencode.json             |
| `skills`      | no       | []                   | Skill names the job should use; injected into the prompt as an instruction |
| `model`       | no       | opencode default     | Model override, e.g. `anthropic/claude-haiku-4-5`|
| `working_dir` | no       | `~`                  | Directory opencode runs in (affects project context) |
| `on_success`  | no       | —                    | Shell command to run if opencode exits 0         |
| `on_failure`  | no       | —                    | Shell command to run if opencode exits non-zero  |

## Naming rules

Unit names must be valid systemd unit names:
- Lowercase, alphanumeric and hyphens only
- Prefix all units with `oc-` to namespace them
- Service: `oc-<name>.service`
- Timer:   `oc-<name>.timer`

## Step 1 — Ensure the registry exists

```bash
mkdir -p ~/.config/opencode-scheduler
```

Write `~/.config/opencode-scheduler/jobs.json` if it does not exist:

```json
[]
```

## Step 2 — Build the opencode command

Construct the opencode CLI invocation from the parameters.

Fresh mode (default):

```bash
opencode run \
  [--agent <agent>] \
  [--model <model>] \
  "<prompt>"
```

Attach mode (requires the Unix socket plugin):

```bash
curl --unix-socket <socket> \
  -X POST http://localhost/session/<session>/message \
  -H 'Content-Type: application/json' \
  -d '{"parts":[{"type":"text","text":"<prompt>"}]}'
```

- `POST /session/<id>/message` sends the prompt and waits for the reply, so the
  service exits when the agent is done (enables `on_success`/`on_failure`).
  Use `POST /session/<id>/prompt_async` to fire-and-forget instead.
- Omit `<session>` (or use the plugin's active-session resolution) to target
  the currently active session.
- Non-interactive `run` already streams output to stdout, which systemd
  captures in the journal — there is no `--print` flag.
- There is no `--skill` CLI flag. To load skills for a job, append an
  instruction to the prompt, e.g. `Load and use the skills: <skill1>, <skill2>`.
- Omit optional flags when their parameter was not provided.
- Shell-escape the prompt string.

## Step 3 — Write the service unit

Write `~/.config/systemd/user/oc-<name>.service`:

```ini
[Unit]
Description=opencode scheduled job: <name>
After=network.target

[Service]
Type=oneshot
WorkingDirectory=<working_dir>
ExecStart=<opencode command from step 2>
ExecStartPost=<on_success command, omit line if not set>
ExecStopPost=<on_failure command using Condition, omit if not set>
StandardOutput=journal
StandardError=journal
SyslogIdentifier=oc-<name>
```

For on_failure, use this pattern so it only fires on non-zero exit:

```ini
ExecStopPost=/bin/sh -c 'if [ $EXIT_STATUS != 0 ]; then <on_failure command>; fi'
```

## Step 4 — Write the timer unit

Write `~/.config/systemd/user/oc-<name>.timer`:

```ini
[Unit]
Description=opencode scheduler timer: <name>

[Timer]
OnCalendar=<schedule>
Persistent=true

[Install]
WantedBy=timers.target
```

`Persistent=true` means if the machine was off when a run was due,
it fires immediately on next boot rather than skipping.

## Step 5 — Update the registry

Read `~/.config/opencode-scheduler/jobs.json`, add or replace the entry
for this job name, and write it back:

```json
{
  "name": "<name>",
  "schedule": "<schedule>",
  "prompt": "<prompt>",
  "mode": "fresh | attach",
  "socket": "<socket path or null>",
  "session": "<session id or null>",
  "agent": "<agent or null>",
  "skills": ["<skill1>", "<skill2>"],
  "model": "<model or null>",
  "working_dir": "<working_dir>",
  "on_success": "<command or null>",
  "on_failure": "<command or null>",
  "created": "<ISO timestamp>",
  "updated": "<ISO timestamp>"
}
```

## Step 6 — Enable and start

```bash
systemctl --user daemon-reload
systemctl --user enable --now oc-<name>.timer
```

Confirm with:

```bash
systemctl --user list-timers oc-<name>.timer
```

Report the next scheduled run time to the user.

## Attach mode notes

- **Requires the opencode Unix socket plugin.** The plugin runs inside the TUI
  process and binds a Unix socket (e.g. `/run/user/1000/opencode.sock`) that
  proxies to the in-process opencode server. Without the plugin, a plain TUI
  exposes no socket and no external process can reach the session.
- The socket lives and dies with the TUI: no TUI running, no active session to
  inject into. Attach jobs should fail gracefully (via `on_failure`) when the
  socket is absent.
- The socket speaks HTTP — the same opencode API a server would expose.
  `curl --unix-socket <path>` connects to the file path instead of a TCP host.
- `session` targets a specific session; omit it to target the active session.
- In attach mode, the session's own permission config governs tool use (the
  injected prompt runs in that session's context). In fresh mode, non-interactive
  runs auto-reject permission requests — pre-approve tools or pass `--auto`
  (auto-approves everything not explicitly denied; use only for trusted jobs).
- Verify the socket exists first: `test -S <socket>` or
  `curl --unix-socket <socket> http://localhost/global/health`.

## Listing all scheduled jobs

When asked to list jobs:

```bash
cat ~/.config/opencode-scheduler/jobs.json
```

Also show live timer status:

```bash
systemctl --user list-timers 'oc-*'
```

Present both together so the user sees both the registry metadata and
the next scheduled run time.

## Updating a job

When asked to change the schedule, prompt, skills, or any other parameter:
1. Read the registry, find the entry by name
2. Apply the changes
3. Rewrite the affected unit file(s)
4. Write the updated registry entry
5. Run:
```bash
   systemctl --user daemon-reload
   systemctl --user restart oc-<name>.timer
```

## Removing a job

When asked to remove, delete, or stop a scheduled job:

```bash
systemctl --user disable --now oc-<name>.timer
systemctl --user disable --now oc-<name>.service
rm ~/.config/systemd/user/oc-<name>.timer
rm ~/.config/systemd/user/oc-<name>.service
systemctl --user daemon-reload
```

Then remove the entry from jobs.json and write it back.

## OnCalendar expression guide

Help the user translate natural language into OnCalendar expressions:

| Natural language          | OnCalendar expression     |
|---------------------------|---------------------------|
| Every 15 minutes          | `*:0/15`                  |
| Every hour                | `hourly`                  |
| Every day at 9am          | `*-*-* 09:00:00`          |
| Weekdays at 9am           | `Mon..Fri 09:00`          |
| Every Monday at 8am       | `Mon 08:00`               |
| Twice a day               | `*-*-* 09,18:00:00`       |
| On boot (once)            | use `After=` not a timer  |

If unsure, suggest `systemd-analyze calendar "<expression>"` to validate.