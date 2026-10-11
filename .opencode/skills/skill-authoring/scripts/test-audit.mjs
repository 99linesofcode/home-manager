#!/usr/bin/env node
/**
 * Self-test for audit-skills.mjs — proves each detector fires on a fixture and
 * stays quiet on a clean one.
 *
 * Run it after changing the audit script:
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/test-audit.mjs
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const AUDIT = path.join(HERE, 'audit-skills.mjs');

const FRONT = '---\nname: {name}\ndescription: A {name} skill.\n---\n\n# {name}\n\nIntro.\n\n';

function skillBody(name, files, body, external) {
    let s = FRONT.replace(/{name}/g, name);
    s += '## Related\n\n- **Loads:** (none)\n- **References:** (none)\n\n';
    s += '## Files\n\n| File | Load | Read when |\n|---|---|---|\n';
    for (const [p, load, when] of files) s += `| \`${p}\` | ${load} | ${when} |\n`;
    if (external) {
        s += '\n## External\n\n| Path | Load | Read when |\n|---|---|---|\n';
        for (const [p, load, when] of external) s += `| \`${p}\` | ${load} | ${when} |\n`;
    }
    s += '\n## Body\n\n' + body + '\n';
    return s;
}

function mkroot() {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'audit-skills-'));
    fs.mkdirSync(path.join(root, '.opencode', 'skills'), { recursive: true });
    return root;
}

function write(root, rel, text) {
    const p = path.join(root, '.opencode', 'skills', rel);
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, text);
}

function run(root, ...args) {
    const proc = spawnSync(process.execPath, [AUDIT, '--root', root, ...args], { encoding: 'utf8' });
    return (proc.stdout || '') + (proc.stderr || '');
}

function runDir(...args) {
    const proc = spawnSync(process.execPath, [AUDIT, ...args], { encoding: 'utf8' });
    return (proc.stdout || '') + (proc.stderr || '');
}

const checks = [];
function check(name, ok, detail) {
    checks.push([name, ok, detail]);
}

// ---------------------------------------------------------------- fixtures

function buildDirty(root) {
    write(root, 'peer/SKILL.md', skillBody('peer', [], 'Peer body.'));
    write(root, 'peer/references/other.md', '# other\n\nOwned by peer.\n');
    write(root, 'othere/SKILL.md', skillBody('othere', [], 'Other skill body.'));
    write(root, 'dirty/references/small.md', '# small\n\n' + 'x'.repeat(80));
    write(root, 'dirty/references/huge.md', '# huge\n\n' + ('A rule MUST hold.\n'.repeat(700)));
    const body = [
        'Full detail: `references/small.md`.',
        'The shared file is `references/other.md` from a peer.',
        'The rule is single-sourced in the `othere` skill.',
        'See ~/Development/some-repo for the reference implementation.',
        'Worked example (2026-01-01): OPM did the thing, and the bug followed.',
    ].join('\n\n');
    write(root, 'dirty/SKILL.md', skillBody('dirty', [
        ['references/small.md', 'on-demand', 'when the small table is needed'],
        ['references/huge.md', 'required', 'always'],
    ], body));
}

function buildClean(root) {
    write(root, 'clean/references/lookup.md', '# lookup\n\n' + 'x'.repeat(2200));
    write(root, 'clean/SKILL.md', skillBody('clean', [
        ['references/lookup.md', 'on-demand', 'when the lookup table is needed'],
    ], 'A neutral statement. Nothing here depends on an outside path.'));
}

// ------------------------------------------------------------------- tests

const dirty = mkroot();
const clean = mkroot();
try {
    buildDirty(dirty);
    buildClean(clean);

    const p = run(dirty, '--pointers');
    check('pointers: on-demand under 2 KB', p.includes('UNDER 2 KB'), p);
    check('pointers: required over 8 KB', p.includes('REQUIRED OVER 8 KB'), p);
    check('pointers: rule behind a pointer', p.includes('**Rule behind a pointer**'), p);
    check('pointers: cross-skill file dependency', p.includes('references/other.md (owned by peer)'), p);
    check('pointers: prose deferral not in Loads', p.includes('**Prose deferral to a skill not in Loads**'), p);
    check('pointers: undeclared external pointer', p.includes('Undeclared external pointer'), p);
    check('pointers: totals show counts', /on-demand knowledge references under 2 KB: 1/.test(p), p);

    const g = run(dirty, '--generic', '--no-discover', '--projects', 'OPM');
    check('generic: dated anecdote', g.includes('[dated'), g);
    check('generic: worked example', g.includes('worked-example'), g);
    check('generic: project name', g.includes('project-name'), g);

    const pc = run(clean, '--pointers');
    check('clean pointers: no under-2KB finding', !pc.includes('UNDER 2 KB'), pc);
    check('clean pointers: no rule-behind-pointer finding', !pc.includes('**Rule behind a pointer**'), pc);
    check('clean pointers: no deferral finding', !pc.includes('**Prose deferral'), pc);
    check('clean pointers: no external finding', !pc.includes('Undeclared external pointer'), pc);

    const gc = run(clean, '--generic', '--no-discover', '--projects', 'OPM');
    check('clean generic: no dated finding', !gc.includes('[dated'), gc);
    check('clean generic: no project-name finding', !gc.includes('project-name,'), gc);

    // declared External silences the external detector
    const ext = mkroot();
    write(ext, 'ext/references/lookup.md', '# l\n\n' + 'x'.repeat(2200));
    write(ext, 'ext/SKILL.md', skillBody('ext', [['references/lookup.md', 'on-demand', 'when needed']],
        'See ~/Development/some-repo for details.', [['~/Development/some-repo', 'on-demand', 'when the reference is unclear']]));
    const pe = run(ext, '--pointers');
    check('declared External silences the external detector', !pe.includes('Undeclared external pointer'), pe);
    fs.rmSync(ext, { recursive: true, force: true });

    // --rules and --diff-rules operate on a directory
    const rulesDir = mkroot();
    write(rulesDir, 'r/SKILL.md', skillBody('r', [], 'You MUST keep this rule.\n\nAnd NEVER lose it.'));
    const rules = runDir('--rules', path.join(rulesDir, '.opencode', 'skills', 'r'));
    check('rules: one line per normative statement', (rules.match(/^\- \[[0-9a-f]{8}\]/gm) || []).length === 2, rules);
    fs.rmSync(rulesDir, { recursive: true, force: true });

    const oldDir = mkroot();
    const newDir = mkroot();
    write(oldDir, 'r/SKILL.md', skillBody('r', [], 'You MUST keep this rule.\n\nAnd NEVER lose it.'));
    write(newDir, 'r/SKILL.md', skillBody('r', [], 'You MUST keep this rule.'));
    const diff = runDir('--diff-rules',
        path.join(oldDir, '.opencode', 'skills', 'r'),
        path.join(newDir, '.opencode', 'skills', 'r'));
    check('diff-rules: reports the missing rule', /Missing from new: 1/.test(diff) && diff.includes('never lose it'), diff);
    fs.rmSync(oldDir, { recursive: true, force: true });
    fs.rmSync(newDir, { recursive: true, force: true });
} finally {
    fs.rmSync(dirty, { recursive: true, force: true });
    fs.rmSync(clean, { recursive: true, force: true });
}

let failures = 0;
for (const [name, ok, detail] of checks) {
    console.log(`${ok ? 'PASS' : 'FAIL'}: ${name}`);
    if (!ok) {
        failures++;
        console.log(detail);
    }
}
console.log(`\n${checks.length} checks; ${failures} failure(s)`);
process.exit(failures ? 1 : 0);
