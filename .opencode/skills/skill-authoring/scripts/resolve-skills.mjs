#!/usr/bin/env node
/**
 * Resolve a skill or a routing-matrix row into its flat required set.
 *
 * Prints the absolute path of each skill in the transitive `Loads` closure (in
 * order), followed by each skill's `required` files; `on-demand` files are
 * listed separately with their triggers. This is the output the orchestrator
 * pastes into a worker package so a worker (which cannot load skills) reads the
 * exact required set.
 *
 * Thin wrapper over `lint-skills.mjs --resolve`.
 *
 * Run it from the repository root (no node on PATH needed on NixOS):
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
