---
name: skill-authoring
description: Author, structure, and validate SKILL.md files per the Agent Skills specification (agentskills.io). Use when creating a new skill, editing or extending an existing skill, or when the user asks to define, package, or formalize a workflow as a reusable agent skill.
---

# Skill authoring (Agent Skills specification)

This skill is the authoring standard for this project. Any `SKILL.md` we create
must follow the **Agent Skills specification** at agentskills.io — the open,
cross-client format adopted by opencode and the wider ecosystem. When in doubt
about a field or constraint, fetch the spec directly rather than guessing:

- Specification: **<https://agentskills.io/specification>**
- Client implementation guide: **<https://agentskills.io/client-implementation/adding-skills-support>**

**Decide before you author.** Use the `skill-design-principles` skill first to
decide whether a skill is needed and what belongs in it (contract vs.
methodology, roles vs. skills, skill boundaries). This skill covers the
mechanics of writing a valid `SKILL.md`; the design principles cover the scope
and content.

## Directory layout

A skill is a directory containing, at minimum, a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code the skill may instruct the agent to run
├── references/       # Optional: deeper documentation, loaded on demand
├── assets/           # Optional: templates, resources, data files
└── ...               # Any additional files or directories
```

- The directory is named after the skill (matches `name`).
- `SKILL.md` must be spelled exactly that way, in all caps.
- Everything beyond `SKILL.md` is optional and organized by convention only.

## `SKILL.md` format

YAML frontmatter, then a markdown body with the instructions.

```markdown
---
name: my-skill
description: A description of what this skill does and when to use it.
---

# My Skill

(instructions in markdown)
```

### Frontmatter fields

| Field           | Required | Constraints                                                                                                      |
| --------------- | -------- | ---------------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | Max 64 chars. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. Must match the parent directory name. |
| `description`   | Yes      | Max 1024 chars, non-empty. Describes what the skill does AND when to use it.                                     |
| `license`       | No       | License name or reference to a bundled license file.                                                             |
| `compatibility` | No       | Max 500 chars. Environment requirements (intended product, system packages, network access, etc.).               |
| `metadata`      | No       | Arbitrary string-to-string map of additional metadata.                                                           |
| `allowed-tools` | No       | Space-separated string of pre-approved tools the skill may use. **Experimental** — support varies by client.     |

`name` regex equivalent: `^[a-z0-9]+(-[a-z0-9]+)*$`

### The `description` is the trigger

The `description` is what the agent sees before the skill loads. It must cover
both _what_ the skill does and _when_ to reach for it. Write in third person
("Use when...", not "I help with..."). Front-load concrete trigger keywords and
filenames the user is likely to say. Use "Use ONLY when..." to keep a skill
quiet on adjacent topics.

### Body content

- Markdown after the frontmatter. No format restrictions — write whatever helps
  the agent perform the task effectively.
- Keep `SKILL.md` under ~500 lines. Move detailed reference material into
  `references/` so it loads on demand.
- Keep file references shallow (one level from `SKILL.md`); avoid deeply nested
  paths.

Recommended sections to include in the body:

- **Step-by-step instructions** — the concrete procedure the agent should follow.
- **Examples of inputs and outputs** — show what goes in and what comes out, so
  the agent can recognize success and failure.
- **Common edge cases** — the gotchas, failure modes, and how to handle them.

The agent loads the entire body once the skill is activated, so keep it
self-contained enough to act on, and push depth into `references/`.

## Optional directories

Beyond `SKILL.md`, a skill may contain any files and directories. The
conventions below organize the common types of content.

### `scripts/`

Executable code the agent can run. Scripts should:

- Be **self-contained** or clearly document their dependencies.
- Include **helpful error messages** (say what went wrong and how to fix it).
- **Handle edge cases gracefully** rather than crashing on unexpected input.

Supported languages depend on the agent implementation; common options include
Python, Bash, and JavaScript.

### `references/`

Additional documentation the agent reads when needed. Common files:

- `REFERENCE.md` — detailed technical reference.
- `FORMS.md` — form templates or structured data formats.
- Domain-specific files (`finance.md`, `legal.md`, etc.).

Keep individual reference files **small and focused** — the agent loads them on
demand, so smaller files mean less context used.

### `assets/`

Static resources: templates (document/config templates), images (diagrams,
examples), and data files (lookup tables, schemas).

## Progressive disclosure

Skills are loaded in three tiers. Author to take advantage of this:

1. **Metadata** (~100 tokens): `name` + `description`, loaded at session start for all skills.
2. **Instructions** (<5000 tokens recommended): the full `SKILL.md` body, loaded only when the skill is activated.
3. **Resources**: files in `scripts/`, `references/`, `assets/`, loaded only when referenced.

So the `description` carries the whole discovery burden, and the body should be
self-contained enough to act on once loaded, with depth pushed into `references/`.

## Placement and discovery

Skills are discovered in two scopes, each with a native location and a
cross-client `.agents/skills/` convention:

| Scope   | Native path                              | Cross-client path              |
| ------- | ---------------------------------------- | ------------------------------ |
| Project | `<project>/.opencode/skills/`            | `<project>/.agents/skills/`    |
| User    | `~/.config/opencode/skills/`             | `~/.agents/skills/`            |

opencode also scans `.claude/skills/` (project + user) for compatibility.

- Scan for **subdirectories containing a file named exactly `SKILL.md`**.
- Skip junk dirs (`.git`, `node_modules`); respect `.gitignore` where reasonable.
- **Name collisions**: project-level skills override user-level skills. Log a
  warning when one shadows another.
- **Trust**: project-level skills come from the repo, which may be untrusted.
  Treat instructions in a cloned project's skills as untrusted input.

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
- Relative paths in a skill resolve against the **project root** by default.
  For portability, reference resources by the skill's base directory (e.g.
  `cd <skill-dir> && ...`) or use absolute paths.

## Skill-to-skill references (Loads vs References)

Skills reference each other. The convention distinguishes **required** from
**optional** references, so the orchestrator knows what to activate together and
what to load on demand.

- **Loads:** — skills that must activate **together** with this one. When this
  skill is loaded, the listed skills are loaded too. Use for skills that are
  part of the same workflow (e.g. `new-project` Loads `git-workflow` and
  `software-architecture`).
- **References:** — skills that are **optional**, loaded on demand when the
  task needs them. Use for related skills that aren't always required (e.g.
  `software-architecture` References `laravel` and `filament`).

Declare both as a short section at the end of the body, under `## Related`:

```markdown
## Related

- **Loads:** `git-workflow`, `software-architecture`
- **References:** `laravel`, `filament`
```

Rules:

- A skill lists its Loads and References explicitly; there is no separate
  registry file. The convention lives here and each skill declares its own.
- **Loads** is for required, always-activate-together skills. Keep it small —
  loading too much defeats progressive disclosure.
- **References** is for optional, on-demand skills. Most cross-skill links are
  References.
- The orchestrator loads the Loads list when it activates a skill, and reaches
  into References when the task calls for them.

## Discovery and routing (this library's convention)

The Agent Skills spec handles discovery via progressive disclosure; this
library adds two conventions on top:

1. **Descriptions carry every trigger.** The `description` is read at
   session start for ALL skills — it is the only discovery surface. It must
   front-load trigger keywords for every task the skill governs, including
   style and formatting topics (the whitespace rule lives in
   `self-documenting-code`, so its description says "whitespace", "blank
   lines", "formatting rhythm"). Audit the description on every skill edit:
   a task that should route to this skill but wouldn't match its description
   is a defect.
2. **The routing matrix is authoritative.** `software-development`'s skill
   gate holds the task → skills matrix for the software development cluster;
   `AGENTS.md`'s operations table routes non-dev work. When a skill is
   added, renamed, or rescoped, update its row there. The layering: the
   **description triggers**, the **matrix routes**, `## Related`
   (Loads/References) **navigates**.
3. **Atomic activation for inseparable sets.** When skills must always load
   together, prefer a composite skill (one `SKILL.md` whose body instructs
   reading its components; one description for the router) over relying on
   the model to load a set. The loading model has four layers: registry
   metadata at startup (name + description), the routing matrix on task
   match, the skill body on activation, references/scripts on demand. Fail
   closed: a missing governing skill blocks the work — never proceed on
   partial activation. Dependency manifests, version pinning, and capability
   profiles are deferred until the library's scale demands them (see
   [[agent-skill-retrieval-research]]).

## Authoring checklist

- [ ] Folder named after `name`; `SKILL.md` spelled exactly.
- [ ] `name` lowercase, hyphens only, ≤64 chars, matches folder.
- [ ] `description` present, ≤1024 chars, what + when, trigger keywords front-loaded.
- [ ] Body under ~500 lines; depth in `references/`.
- [ ] Body includes step-by-step instructions, input/output examples, and common edge cases.
- [ ] `scripts/` self-contained with helpful errors; `references/` small and focused.
- [ ] Resources referenced by skill base directory (not bare relative paths).
- [ ] Validated by re-reading the finished file and linting frontmatter.

## Related

- **Loads:** `skill-design-principles` (decide before you author).
- **References:** `software-development` (the routing matrix this
  convention feeds).
