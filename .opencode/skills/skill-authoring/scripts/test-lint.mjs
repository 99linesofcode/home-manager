#!/usr/bin/env node
/**
 * Self-test for lint-skills.mjs — proves it fails closed on real violations.
 *
 * For each case it builds a throwaway fixture, mutates it, runs the linter, and
 * asserts the expected diagnostic appears and the exit code is non-zero. Also
 * proves the clean repo passes and the resolver expands parts.
 *
 * Run it after changing the linter:
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/test-lint.mjs
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const LINT = path.join(HERE, 'lint-skills.mjs');

function findRoot(start) {
    let d = start;
    for (let i = 0; i < 8; i++) {
        const parent = path.dirname(d);
        if (parent === d) break;
        d = parent;
        if (fs.existsSync(path.join(d, '.opencode', 'skills'))) return d;
    }
    return null;
}

const REPO = findRoot(HERE);
if (!REPO) {
    console.error('test-lint: could not locate .opencode/skills above this file');
    process.exit(2);
}
const SKILLS = path.join(REPO, '.opencode', 'skills');

const FRONT =
    '---\nname: {name}\ndescription: {desc}\n---\n\n# {name}\n\nIntro.\n\n' +
    '## Related\n\n- **Loads:** (none)\n- **References:** (none)\n\n' +
    '## Body\n\nText.\n';

function run(root, ...extra) {
    const proc = spawnSync(process.execPath, [LINT, '--root', root, ...extra], { encoding: 'utf8' });
    return { code: proc.status, out: (proc.stdout || '') + (proc.stderr || '') };
}

function copySkills(root) {
    fs.mkdirSync(path.join(root, '.opencode'), { recursive: true });
    fs.cpSync(SKILLS, path.join(root, '.opencode', 'skills'), { recursive: true });
    const agents = path.join(REPO, '.opencode', 'agents');
    if (fs.existsSync(agents)) fs.cpSync(agents, path.join(root, '.opencode', 'agents'), { recursive: true });
}

function skillText(name, body, files, external) {
    let s = FRONT.replace('{name}', name).replace('{desc}', 'D.');
    if (files) {
        s = s.replace('## Body', '## Files\n\n| File | Load | Read when |\n|---|---|---|\n' + files.map(([p, l, w]) => `| \`${p}\` | ${l} | ${w} |`).join('\n') + '\n\n## Body');
    }
    if (external) {
        s = s.replace('## Body', '## External\n\n| Path | Load | Read when |\n|---|---|---|\n' + external.map(([p, l, w]) => `| \`${p}\` | ${l} | ${w} |`).join('\n') + '\n\n## Body');
    }
    return s.replace('Text.\n', body + '\n');
}

function write(root, rel, text) {
    const p = path.join(root, '.opencode', 'skills', rel);
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, text);
}

function edit(root, rel, from, to) {
    const p = path.join(root, '.opencode', 'skills', rel);
    fs.writeFileSync(p, fs.readFileSync(p, 'utf8').replace(from, to));
}

const CASES = [
    [
        'undeclared reference file',
        "undeclared file 'references/extra.md'",
        (root) => {
            copySkills(root);
            write(root, 'rails/references/extra.md', '# orphan\n');
        },
    ],
    [
        'dangling Related target',
        "dangling Loads target 'no-such-skill'",
        (root) => {
            copySkills(root);
            edit(root, 'wiki/SKILL.md', '- **Loads:** (none — loaded on demand)', '- **Loads:** `no-such-skill`');
        },
    ],
    [
        'matrix/Loads mismatch',
        "companion 'kubernetes' not in 'filament' Loads",
        (root) => {
            copySkills(root);
            edit(root, 'software-development/SKILL.md', '`filament` (+ `laravel`)', '`filament` (+ `kubernetes`)');
        },
    ],
    [
        'name does not match directory',
        "name 'wiki' does not match directory",
        (root) => {
            copySkills(root);
            fs.renameSync(path.join(root, '.opencode/skills/wiki'), path.join(root, '.opencode/skills/wiki-renamed'));
        },
    ],
    [
        'Loads cycle',
        'Loads cycle detected',
        (root) => {
            copySkills(root);
            write(root, 'cycle-a/SKILL.md', FRONT.replace('{name}', 'cycle-a').replace('{desc}', 'A.').replace('- **Loads:** (none)', '- **Loads:** `cycle-b`'));
            write(root, 'cycle-b/SKILL.md', FRONT.replace('{name}', 'cycle-b').replace('{desc}', 'B.').replace('- **Loads:** (none)', '- **Loads:** `cycle-a`'));
        },
    ],
    [
        'trivial on-demand trigger',
        "needs a concrete 'Read when' trigger",
        (root) => {
            copySkills(root);
            edit(root, 'discovery-interview/SKILL.md', 'when the domain is complex — many events, rules, or actors', 'for more detail');
        },
    ],
    [
        'nested SKILL.md',
        'nested SKILL.md',
        (root) => {
            copySkills(root);
            write(root, 'wiki/references/SKILL.md', '# not a skill\n');
        },
    ],
    [
        "part missing 'Part of' prefix",
        'description must begin',
        (root) => {
            copySkills(root);
            let parent = FRONT.replace('{name}', 'demo').replace('{desc}', 'Demo parent.');
            parent += '\n## Parts\n\n| Part | Order | Required | Load when |\n|---|---|---|---|\n| `demo-alpha` | 1 | required | always |\n';
            parent = parent.replace('- **Loads:** (none)', '- **Loads:** `demo-alpha`');
            write(root, 'demo/SKILL.md', parent);
            write(root, 'demo-alpha/SKILL.md', FRONT.replace('{name}', 'demo-alpha').replace('{desc}', 'Alpha part.'));
        },
    ],
    [
        'on-demand reference under 2 KB',
        'inline it into SKILL.md',
        (root) => {
            copySkills(root);
            write(root, 'demo/references/small.md', '# small\n\n' + 'x'.repeat(60));
            write(root, 'demo/SKILL.md', skillText('demo', 'Body.', [['references/small.md', 'on-demand', 'when the small table is needed']]));
        },
    ],
    [
        'required reference over 8 KB',
        'promote it to a skill',
        (root) => {
            copySkills(root);
            write(root, 'demo/references/huge.md', '# huge\n\n' + ('A rule MUST hold.\n'.repeat(700)));
            write(root, 'demo/SKILL.md', skillText('demo', 'Body.', [['references/huge.md', 'required', 'always']]));
        },
    ],
    [
        'malformed External row',
        'is malformed',
        (root) => {
            copySkills(root);
            let s = FRONT.replace('{name}', 'demo').replace('{desc}', 'D.');
            s = s.replace('## Body', '## External\n\n| Path | Load | Read when |\n|---|---|---|\n| `~/Development/thing` | on-demand |\n\n## Body');
            write(root, 'demo/SKILL.md', s);
        },
    ],
    [
        'total load over the cap',
        'total load (SKILL.md + required files)',
        (root) => {
            copySkills(root);
            write(root, 'demo/references/ref.md', '# ref\n\n' + 'x'.repeat(3000));
            write(root, 'demo/SKILL.md', skillText('demo', ('x'.repeat(1800) + '\n').repeat(10), [['references/ref.md', 'required', 'always']]));
        },
    ],
    [
        'stale budget exception',
        'remove the exception',
        (root) => {
            copySkills(root);
            write(root, 'agent-delegation/SKILL.md', skillText('agent-delegation', 'Body.', null));
        },
    ],
    [
        'card out of sync',
        'does not contain the card',
        (root) => {
            copySkills(root);
            write(root, 'demo/SKILL.md', skillText('demo', '<!-- card:start -->\nCARD BODY\n<!-- card:end -->\n', null));
        },
    ],
    [
        'catalog schema: skill missing metadata.category',
        'missing/invalid category',
        (root) => {
            copySkills(root);
            write(root, 'demo/SKILL.md', FRONT.replace('{name}', 'demo').replace('{desc}', 'D.'));
        },
    ],
    [
        'catalog schema: skill with an invalid category',
        'missing/invalid category',
        (root) => {
            copySkills(root);
            write(
                root,
                'demo/SKILL.md',
                '---\nname: demo\ndescription: D.\nmetadata:\n  category: bogus\n  route-when: "Use when testing."\n---\n\n' +
                    '# demo\n\nIntro.\n\n## Related\n\n- **Loads:** (none)\n- **References:** (none)\n\n## Body\n\nText.\n',
            );
        },
    ],
    [
        'role brief with an unknown governing id',
        "role brief 'implementer.md': unknown governing skill 'no-such-skill'",
        (root) => {
            copySkills(root);
            edit(
                root,
                'agent-delegation/references/roles/implementer.md',
                'governing: [software-architecture, software-development, self-documenting-code, git-workflow]',
                'governing: [no-such-skill]',
            );
        },
    ],
    [
        'catalog.json out of date',
        'catalog is stale',
        (root) => {
            copySkills(root);
            const p = path.join(root, '.opencode', 'skills', 'catalog.json');
            const catalog = JSON.parse(fs.readFileSync(p, 'utf8'));
            delete catalog.skills.wiki;
            fs.writeFileSync(p, JSON.stringify(catalog, null, 2) + '\n');
        },
    ],
    [
        'generated block missing its end marker',
        'missing generated-block markers',
        (root) => {
            copySkills(root);
            edit(root, 'software-development/SKILL.md', '<!-- generated:end -->', '');
        },
    ],
    [
        'gate drift: matrix_row.criteria key renamed',
        'gate drift',
        (root) => {
            copySkills(root);
            const p = path.join(root, '.opencode', 'skills', 'jev-gates', 'assets', 'gates.json');
            const gates = JSON.parse(fs.readFileSync(p, 'utf8'));
            const criteria = gates.gates.matrix_row.criteria;
            const first = Object.keys(criteria)[0];
            criteria[first + ' (renamed)'] = criteria[first];
            delete criteria[first];
            fs.writeFileSync(p, JSON.stringify(gates, null, 2) + '\n');
        },
    ],
    [
        'allow-listed id that is not a skill',
        'allow-listed but not in catalog',
        (root) => {
            copySkills(root);
            const p = path.join(root, '.opencode', 'agents', 'orchestrator.md');
            fs.writeFileSync(
                p,
                fs.readFileSync(p, 'utf8').replace('        memory: allow', '        memory: allow\n        bogus-skill: allow'),
            );
        },
    ],
    [
        'AGENTS.md operating contract names an unknown skill',
        'operating contract names unknown skill(s): no-such-skill',
        (root) => {
            copySkills(root);
            fs.writeFileSync(
                path.join(root, '.opencode', 'AGENTS.md'),
                '# AGENTS\n\n## Operating contract\n\n| Operation | Skill |\n|---|---|\n| Do a thing | `no-such-skill` |\n',
            );
        },
    ],
];

function tmpRoot() {
    return fs.mkdtempSync(path.join(os.tmpdir(), 'lint-skills-'));
}

function main() {
    let failures = 0;
    for (const [name, expect, setup] of CASES) {
        const root = tmpRoot();
        try {
            setup(root);
            const { code, out } = run(root);
            const ok = code !== 0 && out.includes(expect);
            console.log(`${ok ? 'PASS' : 'FAIL'}: ${name}`);
            if (!ok) {
                failures++;
                console.log(out);
            }
        } finally {
            fs.rmSync(root, { recursive: true, force: true });
        }
    }

    const clean = run(REPO);
    const cleanOk = clean.code === 0;
    console.log(`${cleanOk ? 'PASS' : 'FAIL'}: clean repo exits 0`);
    if (!cleanOk) {
        failures++;
        console.log(clean.out);
    }

    // --fix: a stale catalog is regenerated, so the linter then exits 0.
    const fixRoot = tmpRoot();
    try {
        copySkills(fixRoot);
        const p = path.join(fixRoot, '.opencode', 'skills', 'catalog.json');
        const catalog = JSON.parse(fs.readFileSync(p, 'utf8'));
        delete catalog.skills.wiki;
        fs.writeFileSync(p, JSON.stringify(catalog, null, 2) + '\n');
        const { code, out } = run(fixRoot, '--fix');
        const ok = code === 0 && out.includes('fixed: regenerated the catalog and derived views');
        console.log(`${ok ? 'PASS' : 'FAIL'}: --fix regenerates a stale catalog`);
        if (!ok) {
            failures++;
            console.log(out);
        }
    } finally {
        fs.rmSync(fixRoot, { recursive: true, force: true });
    }

    const root = tmpRoot();
    try {
        fs.mkdirSync(path.join(root, '.opencode/skills/demo'), { recursive: true });
        write(root, 'demo/SKILL.md', FRONT.replace('{name}', 'demo').replace('{desc}', 'D.') + 'filler\n'.repeat(120));
        const git = (...a) => spawnSync('git', a, { cwd: root, encoding: 'utf8' });
        git('init', '-q');
        git('add', '-A');
        git('-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '-qm', 'base');
        write(root, 'demo/SKILL.md', FRONT.replace('{name}', 'demo').replace('{desc}', 'D.'));
        const { code, out } = run(root, '--base', 'HEAD');
        const ok = code !== 0 && out.includes('SKILL.md shrank by');
        console.log(`${ok ? 'PASS' : 'FAIL'}: diff-aware shrink tripwire`);
        if (!ok) {
            failures++;
            console.log(out);
        }
    } finally {
        fs.rmSync(root, { recursive: true, force: true });
    }

    // resolver: a parent resolves its required parts (pattern B)
    const root2 = tmpRoot();
    try {
        copySkills(root2);
        let parent = FRONT.replace('{name}', 'demo').replace('{desc}', 'Demo parent.');
        parent = parent.replace('- **Loads:** (none)', '- **Loads:** `demo-alpha`');
        write(root2, 'demo/SKILL.md', parent);
        write(root2, 'demo-alpha/SKILL.md', FRONT.replace('{name}', 'demo-alpha').replace('{desc}', 'Part of `demo`: load via the parent only'));
        const { code, out } = run(root2, '--resolve', 'demo');
        const ok = code === 0 && out.includes('skills/demo/SKILL.md') && out.includes('skills/demo-alpha/SKILL.md');
        console.log(`${ok ? 'PASS' : 'FAIL'}: resolver expands a parent's required parts`);
        if (!ok) {
            failures++;
            console.log(out);
        }
    } finally {
        fs.rmSync(root2, { recursive: true, force: true });
    }

    console.log(`\n${CASES.length + 4} checks; ${failures} failure(s)`);
    return failures ? 1 : 0;
}

process.exit(main());
