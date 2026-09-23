---
name: beeper-bridge
description: Operate the Beeper↔opencode bridge — attach a Beeper chat to the current opencode session, detach it, or check status. Use when the user says "establish a bridge connection to Beeper", "I'm going AFK", "delegate this to Beeper", or asks to attach/detach/check the Beeper bridge or opencode-beeper-bridge. Covers chat resolution via the Beeper MCP, sops token discovery, and systemd instance management.
---

# Beeper bridge

Bridges a Beeper chat to an opencode session: inbound chat messages are
injected into the session as prompts; assistant output is posted back to the
chat as each text part is produced, so the user sees live progress during a
long-running task. Lets the user delegate work and follow along from their
phone.

Architecture, data flow, and design decisions live in the wiki:
`~/Documents/Obsidian/AI/wiki/concepts/beeper-bridge.md`. This skill is the
operating procedure.

## Hard rules

- **Never store a chat ID.** Chat IDs change on every Beeper re-link; stored
  IDs always drift. Resolve the chat **by name** via the Beeper MCP at attach
  time, every time. Never write a literal chat ID into any durable file
  (skills, wiki, memory, notes). Runtime state (systemd instance names,
  journal output) is fine.
- **Default chat: OpenCode Updates** (Signal group, just Jordy). The trigger
  phrases ("establish a bridge connection", "I'm going AFK", "delegate this to
  Beeper") mean this chat unless the user names another.
- **One bridge per chat.** The systemd instance name is the only state.

## Attach

Instance name format: `<chatId>:<sessionId>` (systemd accepts `:` in instance
names).

### 1. Resolve the session

```bash
curl -s --unix-socket /run/user/1000/opencode.sock http://localhost/session \
  | jq -r 'sort_by(.time.updated) | reverse | .[0] | "\(.id) — \(.title)"'
```

Picks the most recently active session. With multiple plausible candidates,
confirm with the user which one to pin. The bridge pins the session at startup
and never re-resolves it.

### 2. Resolve the chat by name

Use the Beeper MCP `search_chats` tool (the `beeper` server is configured in
opencode.nix and available in every session): search for the chat title, e.g.
`OpenCode Updates`, and take the chat ID from the result. Use it only for
this attach.

Fallback when MCP tools are unavailable — raw JSON-RPC over HTTP. The server
answers as a single SSE message (parse the `data:` line). The token lives in
the sops-rendered dotenv (the `secrets.d` suffix varies per boot — discover
it, never hardcode it):

```bash
SECRET=$(find /run/user/1000/secrets.d -maxdepth 2 -name beeper | head -1)
TOKEN=$(grep -oP '(?<=BEEPER_TOKEN=).*' "$SECRET" | tr -d '"')
```

```bash
curl -s --max-time 10 -X POST http://localhost:23373/v0/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search_chats","arguments":{"query":"OpenCode Updates","limit":10}}}' \
  | grep '^data:' | sed 's/^data: //' | jq -r '.result.content[0].text'
```

The result is markdown containing `## <chat title> (chatID: <n>)`. Extract
with `grep -oP 'chatID: \K\d+' | head -1`.

### 3. Clear stale instances, then start

A running instance pinned to another session is a zombie — it keeps
injecting into a dead conversation. Stop any whose pinned session differs
from the target, then start:

```bash
systemctl --user list-units 'opencode-beeper-bridge@*' --no-pager
systemctl --user stop opencode-beeper-bridge@<otherChat>:<otherSession>
systemctl --user start opencode-beeper-bridge@<chatId>:<sessionId>
```

### 4. Verify

```bash
systemctl --user status opencode-beeper-bridge@<chatId>:<sessionId> --no-pager -l
journalctl --user -u opencode-beeper-bridge@<chatId>:<sessionId> -n 20 --no-pager
```

Healthy startup logs three lines: `starting: chat=<id> socket=...`, `pinned to
session ...`, `subscribed to session ...`. The first assistant turn after
attach is the outbound live check — it posts to the chat when the turn
completes.

## Detach

```bash
systemctl --user stop opencode-beeper-bridge@<chatId>:<sessionId>
```

Detach when the user returns or asks. The bridge also detaches **itself** when
the pinned session stops being the TUI's active one (checked every minute; a
streak of 3 checks naming another session ends the instance) — a stale bridge
never outlives the conversation it was attached to. The unit has no `Install`
section, so nothing auto-starts at login; instances only exist while
explicitly started.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| MCP curl: connection refused | Beeper Desktop not running | Start Beeper, retry |
| MCP HTTP 401 | Token wrong or secret not rendered | Re-read the sops path (step 2) |
| Socket curl fails | opencode not running, or socket plugin not loaded | Check `/run/user/1000/opencode.sock` exists |
| Bridge runs but no outbound posts | Pinned session died (opencode restarted) | Resolve the new session, restart the instance with the new `<sessionId>` |
| Inbound prompts replay old history | Should not happen — cursor seeds at startup | If seen, report as a bridge bug |
| TUI log: plugin reload fails with EADDRINUSE on the socket | A config change reloaded plugins; the original listener still holds the socket | Benign if the step-1 curl still answers — the original listener serves |
| Instance running, pinned to an old conversation's session | Zombie from a previous attach | Stop it; attach fresh (step 3 clears stale instances) |
| Bridge instance exited on its own (journal: "not the active session ... detaching") | Self-detach — the pinned session stopped being the TUI's active one | Expected behavior; re-attach to the current session if wanted |

## Constraints

- `send_message` posts as the user's own account; self-sent messages never
  notify on the user's phone (Signal suppresses them). Accepted limitation.
- The bridge's own client
  (`~/Development/opencode-beeper-bridge/src/Infrastructure/Beeper/BeeperMcpAdapter.ts`)
  only wraps `send_message` and `list_messages`. Chat resolution and any other
  MCP tool go through raw JSON-RPC as in step 2.
- Voice notes inbound are transcribed automatically (ffmpeg + voxtype-onnx);
  no action needed.

## Related

- **Loads:** none
- **References:** none (architecture reference is the wiki page, linked above)
