# Splitting and refactoring a skill

Lookup detail for `skill-authoring`: the patterns for splitting a skill that is
too large, and the procedure for refactoring one back under budget. Loaded on
demand — the rules these support stay in `SKILL.md`.

## Splitting a skill

When a skill is too large (or should not be one skill), there are four patterns.
Pick by the decision rule at the end.

### A. Single skill + `required` files

The `## Files` table with a `required` row (above). Use for a small split of
lookup material the agent needs alongside the body. **Weakness:** the agent has
to make a second call to read the file, and a `required` reference is only
"required" if the agent obeys the instruction — say so explicitly, and keep the
rule itself in `SKILL.md`.

### B. Entry skill + part skills

The parent is `<name>`; the parts are `<name>-<part>`. The parent's body begins
(after the intro) with a `## Parts` table and this instruction:

> Before acting, call the `skill` tool for every `required` part, in order. If
> any part fails to load, stop and report a blocker.

```markdown
## Parts

| Part | Order | Required | Load when |
|---|---|---|---|
| `foo-core` | 1 | required | always |
| `foo-advanced` | 2 | optional | when the advanced path applies |
```

- The parent's `Loads:` equals its required parts.
- Each part's `description` begins "Part of `<parent>`: load via the parent
  only" so it does not trigger on its own.
- Hide parts from discovery with `metadata.opencode/autoinvoke: "false"` where
  supported (see `references/opencode-notes.md`); otherwise rely on the
  description prefix.
- Use B only when a part is independently useful or too large for pattern A.

### C. Build-time composite

Authors keep `parts/*.md` (never named `SKILL.md`). A Nix step concatenates them
in a declared order into a generated `SKILL.md` with a "GENERATED, do not edit"
header. Runtime is a single load. This is the preferred pattern for large skills
whose content is all normative. The linter checks the generated output (not the
`parts/` sources) and fails if it was hand-edited or out of sync.

### D. Plugin or custom tool

A plugin that expands `Loads` when `skill` is called. Research only — see the
design note in the repo's planning scratchpad. Not built.

### The decision rule

1. Is all the content normative and always needed together? Use **C**, or one
   skill within the budget exception.
2. Is part of it lookup material? Use **A**.
3. Is a part useful on its own? Use **B**.

## Refactoring a long skill

When a `SKILL.md` is over budget, work this procedure — in order:

1. **Report size against the budget.** Run `scripts/lint-skills.mjs --stats` —
   note the lines, bytes and estimated tokens, and whether the skill is a
   recorded exception.
2. **Classify the content** as normative or lookup, using the justification test
   ("Would the skill behave differently if this was never read?").
3. **If it is over the cap, split by skill** (pattern B or C above) — do not just
   hide content in `references/`.
4. **Only lookup content moves to `references/`.** Normative content stays in
   `SKILL.md`, or moves to a `required` reference.
5. **Declare every moved file in the `## Files` table** in the same commit, with
   `required` or `on-demand` and a trigger.
6. **Run the linter with `--base`** and the resolver before committing:

   ```bash
   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/lint-skills.mjs --base origin/main
   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/resolve-skills.mjs <skill>
   ```
