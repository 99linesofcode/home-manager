# opencode notes, validation, and the scripts

Lookup detail for `skill-authoring`: how opencode's loader behaves, its
opencode-specific behaviours, and what each `scripts/` tool does. Loaded on
demand — the rules these support stay in `SKILL.md`.

## Validation (lenient, spec-aligned)

opencode's own loader is lenient and cross-client friendly:

- Name doesn't match parent dir → warn, load anyway.
- Name > 64 chars → warn, load anyway.
- Description missing/empty → **skip** the skill (it's the disclosure trigger).
- YAML completely unparseable → skip, log the error.
- Unknown frontmatter fields (e.g. `allowed-tools`) → **ignored silently** by opencode.
- Duplicate skill name → warn; the later-loaded (disk) version replaces the earlier.

So a valid-for-opencode skill needs only `name` + `description`, but author to
the full spec above for portability across clients.

## opencode-specific notes

- opencode stores `{ name, description, location, content }` per skill and
  surfaces them via the `skill` tool; the base directory (parent of `SKILL.md`)
  is provided in the loaded content so relative resource paths can be resolved.
- opencode does **not** implement `allowed-tools` or a skill-script runner. A
  skill may still bundle `scripts/` and instruct the agent to run them, but
  execution goes through the agent's normal tools (bash) under normal
  permission rules — there is no per-skill tool gating.
- **Relative paths resolve from the skill's own directory.** The `skill` tool
  returns the skill's base directory in the loaded content — `Base directory for
  this skill: file://<skill-dir>` — and states that "relative paths in this
  skill (e.g., scripts/, reference/) are relative to this base directory".
  **Verified** against opencode 1.15.10 (2026-10-11, scratch session). Write
  resource references relative to the skill directory; when a worker needs an
  absolute path, resolve it against the skill's base directory.
  The `## Files` table paths are likewise relative to the skill's base directory.
- **The tool's file list is sampled.** The loaded content carries a
  `<skill_files>` list marked "Note: file list is sampled" — it is not a
  complete inventory. Never rely on it; declare files in `## Files`.
- **Hiding a skill.** `metadata: { opencode/autoinvoke: "false" }` (in
  frontmatter, not config) keeps a skill out of the model-facing list while it
  can still be loaded by exact name. Use it for part-skills (see
  `references/splitting-and-refactoring.md`).
- **Permissions.** A `deny` rule both hides a skill from the agent and rejects
  loading; pattern rules such as `"laravel-*": "deny"` are supported.

## Tools (`scripts/`)

The mechanical checks are JavaScript in this skill's `scripts/`; run them from
the repository root with `nix run` (no `node` on PATH needed). They find the
library by walking up for `.opencode/skills`, so they work from any repo root.

| Script | What it does |
|---|---|
| `lint-skills.mjs` | the gate: frontmatter, `Loads`/`References` graph, `## Files`/`## External` tables, size budget, card sync, routing matrix. Exit 1 on error. `--base <ref>`, `--stats`, `--errors-only`, `--root <repo>`. |
| `resolve-skills.mjs <skill\|row>` | the four lists a worker package needs: governing skills, required files, required External pointers, on-demand with triggers. |
| `audit-skills.mjs` | the diagnostic: `--pointers`, `--generic`, `--rules <dir>`, `--diff-rules <old> <new>`. Run **before and after any refactor**. |
| `test-lint.mjs` / `test-audit.mjs` | self-tests; run after editing the corresponding script. |

```bash
nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/lint-skills.mjs
nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/resolve-skills.mjs slice-delivery
nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/audit-skills.mjs --pointers
nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/test-lint.mjs
```
