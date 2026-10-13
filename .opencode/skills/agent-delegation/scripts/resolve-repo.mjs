#!/usr/bin/env node
/**
 * Propose a repository's ecosystems as the filled Environment block the
 * orchestrator pastes into a worker package — so workers run a project's gates
 * through its Nix devshell instead of guessing at `npx` or a bare `node`.
 *
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/agent-delegation/scripts/resolve-repo.mjs [<repo-path>]
 *
 * Defaults to the current working directory. Reports every ecosystem it finds
 * at the repo root, never blocks, and flags its own limits. Deterministic: same
 * repo, same bytes. No network, no writes.
 */

import fs from 'node:fs';
import path from 'node:path';

const NODE_GATES = ['typecheck', 'lint', 'lint:boundaries', 'lint:naming', 'test', 'build', 'format:check'];
const PHP_GATES = ['test', 'lint', 'analyse', 'build'];

const FLAVOURS = ['devshell-node', 'devshell-php', 'devshell-rust'];
const FLAVOUR_LANGUAGES = {
    'devshell-node': 'Node',
    'devshell-php': 'PHP',
    'devshell-rust': 'Rust',
};

function findRepoRoot(start) {
    let dir = path.resolve(start);

    while (true) {
        if (fs.existsSync(path.join(dir, '.git'))) return dir;

        const parent = path.dirname(dir);
        if (parent === dir) return null;
        dir = parent;
    }
}

function readText(file) {
    try {
        return fs.readFileSync(file, 'utf8');
    } catch {
        return '';
    }
}

function readJson(file) {
    try {
        return JSON.parse(fs.readFileSync(file, 'utf8'));
    } catch {
        return null;
    }
}

function detectEcosystems(root) {
    const entries = fs.readdirSync(root);
    const ecosystems = [];

    if (fs.existsSync(path.join(root, 'composer.json'))) ecosystems.push({ language: 'PHP', manager: 'composer' });
    if (fs.existsSync(path.join(root, 'Gemfile')) || entries.some((entry) => entry.endsWith('.gemspec'))) {
        ecosystems.push({ language: 'Ruby', manager: 'bundler' });
    }
    if (fs.existsSync(path.join(root, 'Cargo.toml'))) ecosystems.push({ language: 'Rust', manager: 'cargo' });
    if (fs.existsSync(path.join(root, 'package.json'))) ecosystems.push({ language: 'Node', manager: detectNodeManager(root) });

    return ecosystems;
}

function detectNodeManager(root) {
    if (fs.existsSync(path.join(root, 'pnpm-lock.yaml'))) return 'pnpm';
    if (fs.existsSync(path.join(root, 'package-lock.json'))) return 'npm';
    if (fs.existsSync(path.join(root, 'yarn.lock'))) return 'yarn';
    if (fs.existsSync(path.join(root, 'bun.lockb'))) return 'bun';

    return 'pnpm';
}

function detectDevshell(root) {
    const envrc = readText(path.join(root, '.envrc'));

    if (fs.existsSync(path.join(root, '.envrc')) && /use\s+flake/.test(envrc)) {
        return { kind: 'direnv', flake: readFlakePath(envrc) };
    }

    if (fs.existsSync(path.join(root, 'flake.nix'))) return { kind: 'nix' };

    return { kind: 'none' };
}

function readFlakePath(envrc) {
    const match = envrc.match(/use\s+flake\s+(\S+)/);

    return match ? match[1] : './devshell';
}

function detectFlavour(root) {
    const gitmodules = readText(path.join(root, '.gitmodules'));

    return FLAVOURS.find((name) => gitmodules.includes(name)) || null;
}

function gatesFor(root, ecosystem) {
    if (ecosystem.language === 'Node') return nodeGates(root, ecosystem.manager);
    if (ecosystem.language === 'PHP') return phpGates(root);
    if (ecosystem.language === 'Ruby') return rubyGates(root);

    return rustGates();
}

function nodeGates(root, manager) {
    const scripts = readJson(path.join(root, 'package.json'))?.scripts || {};

    return NODE_GATES.filter((key) => Object.hasOwn(scripts, key)).map((key) => ({
        label: key.split(':').pop(),
        tool: key,
        command: `direnv exec . ${manager} run ${key}`,
    }));
}

function phpGates(root) {
    const scripts = readJson(path.join(root, 'composer.json'))?.scripts || {};

    return PHP_GATES.filter((key) => Object.hasOwn(scripts, key)).map((key) => ({
        label: key,
        tool: key,
        command: `direnv exec . composer ${key}`,
    }));
}

function rubyGates(root) {
    const gates = [];
    const hasSpec = fs.existsSync(path.join(root, '.rspec')) || fs.existsSync(path.join(root, 'spec'));

    if (hasSpec) gates.push({ label: 'test', tool: 'rspec', command: 'direnv exec . bundle exec rspec' });
    if (fs.existsSync(path.join(root, '.rubocop.yml'))) {
        gates.push({ label: 'lint', tool: 'rubocop', command: 'direnv exec . bundle exec rubocop' });
    }

    return gates;
}

function rustGates() {
    return [
        { label: 'test', tool: 'test', command: 'direnv exec . cargo test' },
        { label: 'lint', tool: 'clippy', command: 'direnv exec . cargo clippy' },
        { label: 'build', tool: 'build', command: 'direnv exec . cargo build' },
    ];
}

function devshellEntry(devshell) {
    if (devshell.kind === 'direnv') {
        return `\`direnv exec . <cmd>\` from the repo root (\`.envrc\` → \`use flake ${devshell.flake}\`); \`nix run nixpkgs#<tool> -- <args>\` for a one-off tool.`;
    }

    if (devshell.kind === 'nix') {
        return '`nix develop -c <cmd>` from the repo root (`flake.nix`); `nix run nixpkgs#<tool> -- <args>` for a one-off tool.';
    }

    return 'no devshell detected.';
}

function formatGates(gates) {
    if (gates.length === 0) return [];

    const width = Math.max(...gates.map((gate) => gate.label.length)) + 3;

    return gates.map((gate) => `    ${gate.label.padEnd(width)}${gate.command}`);
}

function nodeFallback(gates) {
    const gate = gates.find((candidate) => candidate.tool === 'test') || gates[0];
    if (!gate || gate.tool === 'test') return 'vitest run';

    return gate.tool;
}

function hasLanguage(ecosystems, language) {
    return ecosystems.some((ecosystem) => ecosystem.language === language);
}

function repositoryLine(root, ecosystems, flavour) {
    const descriptor = ecosystems.map((ecosystem) => `${ecosystem.language} / ${ecosystem.manager}`).join(', ');
    const details = flavour ? `${descriptor}; ${flavour}` : descriptor;

    return `${root} (${details})`;
}

function gatesBlock(root, ecosystems) {
    const lines = [];

    for (const ecosystem of ecosystems) {
        lines.push(`  ${ecosystem.language}:`);
        lines.push(...formatGates(gatesFor(root, ecosystem)));
    }

    return lines;
}

function flavourMismatchNote(flavour, ecosystems) {
    if (!flavour) return null;

    const language = FLAVOUR_LANGUAGES[flavour];
    if (!language || hasLanguage(ecosystems, language)) return null;

    return `- Note: devshell flavour is \`${flavour}\` but no ${language} manifest was found at the repo root — check for a nested one and add its gates by hand.`;
}

function buildOutput(root, ecosystems, devshell, flavour, isGitRepo) {
    const lines = [
        '## Environment (resolved)',
        '',
        '- Platform: NixOS. The project devshell is the environment the gates run in.',
        `- Repository: ${repositoryLine(root, ecosystems, flavour)}.`,
    ];

    if (!isGitRepo) lines.push(`- Note: ${root} is not a git repository.`);

    const node = ecosystems.find((ecosystem) => ecosystem.language === 'Node');
    if (node) {
        lines.push('- Node outside the devshell: none — `npx`, `npm`, and bare `node` are NOT available on PATH. Do not use them.');
    }

    lines.push(`- Devshell entry: ${devshellEntry(devshell)}`);
    lines.push('- Gates — run each exactly as written, from the repo root:');
    lines.push(...gatesBlock(root, ecosystems));

    if (node) {
        const gates = nodeGates(root, node.manager);
        lines.push(`- If ${node.manager} is missing inside the devshell: \`direnv exec . node_modules/.bin/${nodeFallback(gates)}\`.`);
    }

    const mismatch = flavourMismatchNote(flavour, ecosystems);
    if (mismatch) lines.push(mismatch);

    lines.push('- Detection is root-level and advisory; correct this block against the repo.');

    return lines.join('\n') + '\n';
}

function buildUnrecognised(root, devshell) {
    return (
        [
            '## Environment (resolved)',
            '',
            '- Platform: NixOS. The project devshell is the environment the gates run in.',
            `- Repository: ${root}.`,
            "- Ecosystem: not recognised — hand-fill this block from the repo's own manifests.",
            `- Devshell entry: ${devshellEntry(devshell)}`,
            '- Gates: hand-fill — no known manifest at the repo root.',
        ].join('\n') + '\n'
    );
}

function main() {
    const target = process.argv[2] || process.cwd();

    let stats;
    try {
        stats = fs.statSync(target);
    } catch {
        stats = null;
    }

    if (!stats || !stats.isDirectory()) {
        console.error(`resolve-repo: no such directory: ${target}`);
        return 2;
    }

    const gitRoot = findRepoRoot(target);
    const root = gitRoot || path.resolve(target);

    const ecosystems = detectEcosystems(root);
    const devshell = detectDevshell(root);

    if (ecosystems.length === 0) {
        process.stdout.write(buildUnrecognised(root, devshell));
        return 0;
    }

    const flavour = detectFlavour(root);

    process.stdout.write(buildOutput(root, ecosystems, devshell, flavour, gitRoot !== null));

    return 0;
}

process.exit(main());
