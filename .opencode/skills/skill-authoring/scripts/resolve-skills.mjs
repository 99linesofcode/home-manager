#!/usr/bin/env node
/**
 * Resolve a skill or a routing-matrix row into the four lists a worker package
 * needs:
 *
 *   1. Governing skills — the transitive `Loads` closure, as absolute
 *      `SKILL.md` paths, in load order.
 *   2. Required files — every `required` file (references/assets/scripts), as
 *      absolute paths.
 *   3. Required External pointers — every `required` `## External` path,
 *      `~`-expanded, flagged `[MISSING on this machine]` when absent.
 *   4. On-demand — files and pointers with their triggers (add the ones whose
 *      trigger matches the task).
 *
 * A worker cannot load skills, so this output is pasted into the package.
 *
 * Thin wrapper over `lint-skills.mjs --resolve`.
 *
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/resolve-skills.mjs slice-delivery
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/resolve-skills.mjs "Deliver a slice"
 */

import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const args = process.argv.slice(2);
if (args.length < 1) {
    console.error('usage: resolve-skills.mjs <skill-name | matrix-row-text> [--root DIR]');
    process.exit(2);
}

const result = spawnSync(
    process.execPath,
    [path.join(HERE, 'lint-skills.mjs'), '--resolve', args[0], ...args.slice(1)],
    { stdio: 'inherit' },
);
process.exit(result.status ?? 1);
