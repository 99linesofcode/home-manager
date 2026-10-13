#!/usr/bin/env node
/**
 * Self-test for resolve-repo.mjs — builds throwaway fixture repositories under
 * os.tmpdir(), runs the resolver, and asserts the Environment block it emits.
 *
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/agent-delegation/scripts/test-resolve-repo.mjs
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const RESOLVER = path.join(HERE, 'resolve-repo.mjs');

const NODE_PACKAGE = JSON.stringify(
    {
        scripts: {
            typecheck: 'tsc --noEmit',
            lint: 'eslint .',
            'lint:boundaries': 'eslint --config boundaries',
            test: 'vitest run',
            build: 'vite build',
        },
    },
    null,
    2,
) + '\n';

function fixture() {
    return fs.mkdtempSync(path.join(os.tmpdir(), 'resolve-repo-'));
}

function write(root, rel, text) {
    const file = path.join(root, rel);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, text);
}

function nodeFixture(root) {
    write(root, '.git', '');
    write(root, 'package.json', NODE_PACKAGE);
    write(root, 'pnpm-lock.yaml', '');
    write(root, '.envrc', 'use flake ./devshell\n');
    write(
        root,
        '.gitmodules',
        '[submodule "devshell"]\n\tpath = devshell\n\turl = git@github.com:99linesofcode/devshell-node.git\n',
    );
}

function polyglotFixture(root) {
    write(root, '.git', '');
    write(root, 'composer.json', JSON.stringify({ scripts: { test: 'phpunit' } }, null, 2) + '\n');
    write(root, 'package.json', JSON.stringify({ scripts: { build: 'vite build' } }, null, 2) + '\n');
    write(root, 'pnpm-lock.yaml', '');
}

function rustFixture(root) {
    write(root, '.git', '');
    write(root, 'Cargo.toml', '[package]\nname = "demo"\nversion = "0.1.0"\n');
}

function unrecognisedFixture(root) {
    write(root, '.git', '');
}

function run(root) {
    const proc = spawnSync(process.execPath, [RESOLVER, root], { encoding: 'utf8' });

    return { code: proc.status, out: proc.stdout || '', err: proc.stderr || '' };
}

const CASES = [
    {
        name: 'Node / pnpm',
        setup: nodeFixture,
        check: (result) =>
            result.code === 0 &&
            result.out.includes('Node / pnpm') &&
            result.out.includes('direnv exec .') &&
            result.out.includes('direnv exec . pnpm run test'),
    },
    {
        name: 'polyglot PHP / composer + Node / pnpm',
        setup: polyglotFixture,
        check: (result) =>
            result.code === 0 &&
            result.out.includes('PHP / composer') &&
            result.out.includes('Node / pnpm') &&
            result.out.includes('direnv exec . composer test') &&
            result.out.includes('direnv exec . pnpm run build'),
    },
    {
        name: 'Rust / cargo',
        setup: rustFixture,
        check: (result) =>
            result.code === 0 && result.out.includes('Rust / cargo') && result.out.includes('direnv exec . cargo test'),
    },
    {
        name: 'unrecognised ecosystem',
        setup: unrecognisedFixture,
        check: (result) => result.code === 0 && result.out.includes('not recognised'),
    },
];

function main() {
    let failures = 0;

    for (const testCase of CASES) {
        const root = fixture();

        try {
            testCase.setup(root);
            const result = run(root);
            const ok = testCase.check(result);
            console.log(`${ok ? 'PASS' : 'FAIL'}: ${testCase.name}`);

            if (!ok) {
                failures++;
                console.log(result.out);
                console.log(result.err);
            }
        } finally {
            fs.rmSync(root, { recursive: true, force: true });
        }
    }

    console.log(`\n${CASES.length} checks; ${failures} failure(s)`);

    return failures ? 1 : 0;
}

process.exit(main());
