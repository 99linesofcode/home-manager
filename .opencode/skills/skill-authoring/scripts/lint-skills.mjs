#!/usr/bin/env node
/**
 * Lint the opencode skill library.
 *
 * Enforces the Agent Skills specification (agentskills.io) plus this library's
 * conventions: the `## Related` graph (Loads / References), the `## Files`
 * declaration table, the size budget, and the routing matrix in
 * `software-development`. Also resolves a skill or matrix row into the flat,
 * ordered, de-duplicated required set (`--resolve`).
 *
 * Node standard library only. Deterministic output. Exit code 1 on any error.
 * The library root is found by walking up from this file for `.opencode/skills`;
 * override with `--root`.
 *
 * Run it from the repository root (no node on PATH needed on NixOS):
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/lint-skills.mjs
 *
 * Options:
 *   --root DIR        the library root (default: found from this file)
 *   --base GIT_REF    diff-aware check against a git ref (anti-extraction tripwire)
 *   --resolve TARGET  resolve a skill or matrix row to its required set
 *   --stats           print the library metrics
 *   --errors-only     print errors only (no warnings, no summary)
 *   --quiet           print errors and warnings, no summary
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const DEFAULT_MAX_LINES = 500;
const DEFAULT_MAX_BYTES = 20 * 1024; // ~5,000 tokens (bytes / 4)
const HARD_MAX_BYTES = 32 * 1024; // ~8,000 tokens
const MIN_REFERENCE_BYTES = 2 * 1024; // inline-by-default floor for knowledge references
const MAX_REQUIRED_BYTES = 8 * 1024; // a required file over this is a skill
const CARD_START = '<!-- card:start -->';
const CARD_END = '<!-- card:end -->';
const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const DESC_MAX = 1024;
const DESC_WARN = 400;
const MAX_CLOSURE = 4; // transitive Loads closure, excluding self
const MATRIX_SKILL = 'software-development';
const FILES_DIRS = ['references', 'assets', 'scripts'];
// Files exempt from the 2 KB floor and the 8 KB ceiling: role briefs and
// assets are passed by path or filled in; scripts are run, not read.
const SIZE_EXEMPT = [/^references\/roles\//, /^assets\//, /^scripts\//];
const NORMATIVE_WORDS = /\b(MUST|NEVER|REQUIRED|ALWAYS)\b/g;
const NORMATIVE_WORD_THRESHOLD = 12;

// Deliberate size-budget exceptions: a skill over the default budget must be
// listed here with a numeric max_kb (<= 32) and a one-line reason.
const BUDGET_EXCEPTIONS = {
    'skill-authoring': {
        max_kb: 32,
        reason: 'contract skill: the size/reference policy, load policy and splitting patterns are normative and must be in context together',
    },
};

// Skills deliberately outside the software-development routing matrix, each
// with a one-line reason.
const NON_MATRIX_ALLOWLIST = {
    memory: 'cross-cutting memory protocol; routed by the orchestrator prompt',
    wiki: 'LLM-wiki maintenance; a vault operation routed by AGENTS.md',
    'vault-notes': 'always loaded; the vault filing contract',
    'teach-mode': 'teaching mode; not a software-development task',
    'communication-standards': 'always-on writing contract; not a routed dev task',
    'beeper-bridge': 'harness operation (chat bridge); not a dev task',
    'typst-document': 'document rendering; a vault/ops task',
    'research-prompt-skills': 'scheduled standalone job; not a routed dev task',
};

// "Read when" cells that are not concrete triggers.
const TRIVIAL_TRIGGERS = new Set([
    '',
    'for more detail',
    'for more details',
    'for details',
    'for more information',
    'when needed',
    'as needed',
    'if needed',
    'when necessary',
    'if necessary',
    'n/a',
    'none',
    'more detail',
]);

const REQUIRED_INSTRUCTION_RE = /before acting,\s*read(\s*\(or run\))? every .{0,60}required.{0,60}file/i;

const HERE = path.dirname(fileURLToPath(import.meta.url));

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

function readText(p) {
    return fs.readFileSync(p, 'utf8');
}

function unquoteScalar(value) {
    if (value.length >= 2 && value[0] === value[value.length - 1] && `"'\``.includes(value[0])) {
        return value.slice(1, -1);
    }
    return value;
}

function splitFrontmatter(text) {
    if (!text.startsWith('---')) {
        return { fm: {}, error: "missing YAML frontmatter (must start with '---')" };
    }
    const lines = text.split('\n');
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return { fm: {}, error: 'unterminated YAML frontmatter' };
    const fm = {};
    let i = 1;
    while (i < end) {
        const line = lines[i];
        if (!line.trim() || line.trimStart().startsWith('#')) {
            i++;
            continue;
        }
        const m = line.match(/^([A-Za-z0-9_./-]+):\s*(.*)$/);
        if (!m) {
            i++;
            continue;
        }
        const key = m[1];
        let value = m[2].trim();
        if (['|', '>', '|-', '>-'].includes(value)) {
            const block = [];
            i++;
            while (i < end && (lines[i].startsWith(' ') || lines[i] === '')) {
                block.push(lines[i].trim());
                i++;
            }
            fm[key] = block.filter((x) => x).join(' ');
            continue;
        }
        if (value === '') {
            // Descend one level: an empty value followed by an indented block is
            // a nested map (e.g. `metadata:` with 2-space children). Files with
            // no nesting keep their flat parse exactly.
            const nested = {};
            let j = i + 1;
            let sawIndented = false;
            while (j < end) {
                const l = lines[j];
                if (l === '') { j++; continue; }
                if (!/^\s{2,}/.test(l)) break;
                sawIndented = true;
                const nm = l.match(/^\s+([A-Za-z0-9_./-]+):\s*(.*)$/);
                if (nm) nested[nm[1]] = unquoteScalar(nm[2].trim());
                j++;
            }
            if (sawIndented) {
                fm[key] = nested;
                i = j;
                continue;
            }
            fm[key] = '';
            i++;
            continue;
        }
        fm[key] = unquoteScalar(value);
        i++;
    }
    return { fm, error: null };
}

function fenceMask(lines) {
    const mask = [];
    let inFence = false;
    const fenceRe = /^\s*(```|~~~)/;
    for (const line of lines) {
        if (fenceRe.test(line)) {
            mask.push(true);
            inFence = !inFence;
        } else {
            mask.push(inFence);
        }
    }
    return mask;
}

function findHeading(lines, mask, title) {
    const re = new RegExp('^##\\s+' + title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\s*$');
    for (let i = 0; i < lines.length; i++) {
        if (!mask[i] && re.test(lines[i])) return i;
    }
    return null;
}

function sectionEnd(lines, mask, start) {
    for (let i = start + 1; i < lines.length; i++) {
        if (!mask[i] && lines[i].startsWith('## ')) return i;
    }
    return lines.length;
}

function extractNames(text) {
    const out = [];
    const re = /`([^`]+)`/g;
    let m;
    while ((m = re.exec(text)) !== null) {
        if (NAME_RE.test(m[1])) out.push(m[1]);
    }
    return out;
}

function addUnique(target, names) {
    for (const n of names) if (!target.includes(n)) target.push(n);
}

function parseRelated(skill) {
    if (skill.relatedIndex === null) return;
    const lines = skill.lines;
    const mask = fenceMask(lines);
    const end = sectionEnd(lines, mask, skill.relatedIndex);
    let current = null;
    for (let i = skill.relatedIndex + 1; i < end; i++) {
        const line = lines[i];
        const m = line.match(/\s*-\s*\*\*(Loads|References):\*\*(.*)/);
        if (m) {
            current = m[1].toLowerCase();
            const value = m[2];
            const names = value.trim().replace(/^\(/, '').toLowerCase().startsWith('none')
                ? []
                : extractNames(value);
            addUnique(current === 'loads' ? skill.loads : skill.references, names);
            continue;
        }
        if (line.trimStart().startsWith('- ')) {
            current = null;
            continue;
        }
        if (current && line.trim()) {
            addUnique(current === 'loads' ? skill.loads : skill.references, extractNames(line));
        }
    }
}

function parseFilesTable(skill) {
    if (skill.filesIndex === null) return;
    const lines = skill.lines;
    const mask = fenceMask(lines);
    const end = sectionEnd(lines, mask, skill.filesIndex);
    for (let i = skill.filesIndex + 1; i < end; i++) {
        if (mask[i]) continue;
        const line = lines[i].trim();
        if (!line.startsWith('|')) continue;
        const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length < 3) continue;
        const first = cells[0].replace(/`/g, '').trim();
        if (['file', ''].includes(first.toLowerCase()) || [...first].every((c) => '-: '.includes(c))) {
            continue;
        }
        skill.filesRows.push({
            path: first,
            load: cells[1].replace(/`/g, '').trim().toLowerCase(),
            trigger: cells[2].trim(),
        });
    }
}

function parseExternalTable(skill) {
    if (skill.externalIndex === null) return;
    const lines = skill.lines;
    const mask = fenceMask(lines);
    const end = sectionEnd(lines, mask, skill.externalIndex);
    for (let i = skill.externalIndex + 1; i < end; i++) {
        if (mask[i]) continue;
        const line = lines[i].trim();
        if (!line.startsWith('|')) continue;
        const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length < 1) continue;
        const first = cells[0].replace(/`/g, '').trim();
        if (['path', ''].includes(first.toLowerCase()) || [...first].every((c) => '-: '.includes(c))) {
            continue;
        }
        skill.externalRows.push({
            path: first,
            load: (cells[1] || '').replace(/`/g, '').trim().toLowerCase(),
            trigger: (cells[2] || '').trim(),
            cells: cells.length,
        });
    }
}

function walkFiles(dir) {
    const out = [];
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        if (e.isDirectory()) out.push(...walkFiles(p));
        else if (e.isFile()) out.push(p);
    }
    return out;
}

function newSkill(name, dir) {
    return {
        name,
        dir,
        path: path.join(dir, 'SKILL.md'),
        text: '',
        lines: [],
        frontmatter: {},
        description: '',
        loads: [],
        references: [],
        filesRows: [],
        externalRows: [],
        physicalFiles: [],
        relatedIndex: null,
        firstSectionIndex: null,
        filesIndex: null,
        externalIndex: null,
        bytes: 0,
        nlines: 0,
        parseError: null,
    };
}

function requiredFiles(skill) {
    return skill.filesRows.filter((r) => r.load === 'required').map((r) => r.path);
}

function isSizeExempt(rel) {
    return SIZE_EXEMPT.some((re) => re.test(rel));
}

// The catalog `metadata` map is metadata, not body, so it is excluded from the
// size budget; `name`/`description` are still counted (the description has its
// own cap). Returns the byte length of the frontmatter `metadata:` line plus
// its indented continuation lines, including trailing newlines; 0 when absent.
function metadataBytes(skill) {
    const lines = skill.lines;
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return 0;
    for (let i = 1; i < end; i++) {
        if (!/^metadata:/.test(lines[i])) continue;
        let bytes = Buffer.byteLength(lines[i], 'utf8') + 1;
        let j = i + 1;
        while (j < end && /^\s/.test(lines[j])) {
            bytes += Buffer.byteLength(lines[j], 'utf8') + 1;
            j++;
        }
        return bytes;
    }
    return 0;
}

function reportBytes(skill) {
    let total = skill.bytes - metadataBytes(skill);
    for (const rel of requiredFiles(skill)) {
        if (rel.startsWith('scripts/')) continue; // run, not loaded into context
        const p = path.join(skill.dir, rel);
        if (fs.existsSync(p) && fs.statSync(p).isFile()) total += fs.statSync(p).size;
    }
    return total;
}

function loadSkill(dir) {
    const skill = newSkill(path.basename(dir), dir);
    if (!fs.existsSync(skill.path) || !fs.statSync(skill.path).isFile()) {
        skill.parseError = 'no SKILL.md';
        return skill;
    }
    skill.text = readText(skill.path);
    skill.bytes = fs.statSync(skill.path).size;
    skill.lines = skill.text.split('\n');
    skill.nlines = skill.lines.length;
    const { fm, error } = splitFrontmatter(skill.text);
    if (error) {
        skill.parseError = error;
        return skill;
    }
    skill.frontmatter = fm;
    skill.description = fm.description || '';
    const mask = fenceMask(skill.lines);
    skill.relatedIndex = findHeading(skill.lines, mask, 'Related');
    skill.filesIndex = findHeading(skill.lines, mask, 'Files');
    skill.externalIndex = findHeading(skill.lines, mask, 'External');
    const headings = [];
    for (let i = 0; i < skill.lines.length; i++) {
        if (!mask[i] && skill.lines[i].startsWith('## ')) headings.push(i);
    }
    skill.firstSectionIndex = headings.length ? headings[0] : null;
    parseRelated(skill);
    parseFilesTable(skill);
    parseExternalTable(skill);
    for (const p of walkFiles(skill.dir).sort()) {
        const rel = path.relative(skill.dir, p).split(path.sep).join('/');
        if (FILES_DIRS.includes(rel.split('/')[0])) skill.physicalFiles.push(rel);
    }
    return skill;
}

function discover(root) {
    const skillsDir = path.join(root, '.opencode', 'skills');
    const skills = new Map();
    for (const e of fs.readdirSync(skillsDir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
        if (e.isDirectory()) skills.set(e.name, loadSkill(path.join(skillsDir, e.name)));
    }
    return skills;
}

function gitShow(root, ref, relpath) {
    try {
        return execFileSync('git', ['-C', root, 'show', `${ref}:${relpath}`], { encoding: 'utf8' });
    } catch {
        return null;
    }
}

function parseFilesRowsFromText(text) {
    const lines = text.split('\n');
    const mask = fenceMask(lines);
    const idx = findHeading(lines, mask, 'Files');
    if (idx === null) return [];
    const tmp = newSkill('_tmp', '.');
    tmp.lines = lines;
    tmp.filesIndex = idx;
    parseFilesTable(tmp);
    return tmp.filesRows;
}

class Report {
    constructor() {
        this.errors = [];
        this.warnings = [];
    }
    error(msg) {
        this.errors.push(msg);
    }
    warn(msg) {
        this.warnings.push(msg);
    }
}

function checkFrontmatter(skills, rep) {
    const seen = new Map();
    for (const [name, skill] of skills) {
        if (skill.parseError) {
            rep.error(`${name}: ${skill.parseError}`);
            continue;
        }
        const fmName = skill.frontmatter.name || '';
        if (!fmName) rep.error(`${name}: frontmatter missing 'name'`);
        else if (fmName !== name) rep.error(`${name}: name '${fmName}' does not match directory`);
        if (fmName) {
            if (seen.has(fmName)) rep.error(`${name}: duplicate skill name (also in ${seen.get(fmName)})`);
            seen.set(fmName, name);
        }
        const desc = skill.description;
        if (!desc) {
            rep.error(`${name}: frontmatter missing/empty 'description'`);
        } else if (desc.length > DESC_MAX) {
            rep.error(`${name}: description is ${desc.length} chars (> ${DESC_MAX})`);
        } else if (desc.length > DESC_WARN) {
            rep.warn(`${name}: description is ${desc.length} chars (> ${DESC_WARN})`);
        }
    }
}

function checkRelatedTargets(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        if (skill.relatedIndex === null) {
            rep.error(`${name}: no '## Related' section`);
            continue;
        }
        for (const [kind, targets] of [
            ['Loads', skill.loads],
            ['References', skill.references],
        ]) {
            for (const t of targets) if (!skills.has(t)) rep.error(`${name}: dangling ${kind} target '${t}'`);
        }
        for (const t of skill.loads) {
            if (skill.references.includes(t)) rep.error(`${name}: '${t}' is both Loads and References`);
        }
    }
}

function checkRelatedPosition(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError || skill.relatedIndex === null) continue;
        if (skill.firstSectionIndex !== skill.relatedIndex) {
            rep.error(`${name}: '## Related' must be the first section (after the intro)`);
        }
    }
}

function checkFilesTable(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        const declared = new Set(skill.filesRows.map((r) => r.path));
        for (const rel of skill.physicalFiles) {
            if (!declared.has(rel)) rep.error(`${name}: undeclared file '${rel}' (add it to the ## Files table)`);
        }
        for (const row of skill.filesRows) {
            const rel = row.path;
            if (!fs.existsSync(path.join(skill.dir, rel))) {
                rep.error(`${name}: declared file '${rel}' does not exist`);
            }
            if (!['required', 'on-demand'].includes(row.load)) {
                rep.error(`${name}: '${rel}' has load '${row.load}' (must be required|on-demand)`);
            }
            if (row.load === 'on-demand') {
                const trig = row.trigger.trim().toLowerCase().replace(/\.$/, '');
                if (TRIVIAL_TRIGGERS.has(trig) || trig.length < 8) {
                    rep.error(`${name}: on-demand '${rel}' needs a concrete 'Read when' trigger`);
                }
            }
            const full = path.join(skill.dir, rel);
            if (fs.existsSync(full) && fs.statSync(full).isFile() && !isSizeExempt(rel)) {
                const size = fs.statSync(full).size;
                if (row.load === 'on-demand' && size < MIN_REFERENCE_BYTES) {
                    rep.error(`${name}: on-demand '${rel}' is ${size} B (< ${MIN_REFERENCE_BYTES} B) — inline it into SKILL.md`);
                }
                if (row.load === 'required' && size > MAX_REQUIRED_BYTES) {
                    rep.error(`${name}: required '${rel}' is ${size} B (> ${MAX_REQUIRED_BYTES} B) — promote it to a skill`);
                }
            }
        }
        if (requiredFiles(skill).length && !REQUIRED_INSTRUCTION_RE.test(skill.text)) {
            rep.error(
                `${name}: has required files but no 'Before acting, read every \`required\` file' instruction`,
            );
        }
        // referenced resource paths must exist relative to the skill directory;
        // skip fenced code (examples) and placeholders like <lang> or a glob.
        const mask = fenceMask(skill.lines);
        for (let i = 0; i < skill.lines.length; i++) {
            if (mask[i]) continue;
            const re = /`((?:references|assets|scripts)\/[^`]+)`/g;
            let m;
            while ((m = re.exec(skill.lines[i])) !== null) {
                const tok = m[1];
                if ([...tok].some((c) => '<>*'.includes(c))) continue;
                if (tok.endsWith('/')) continue; // a directory reference, not a file
                const rel = tok.split(/\s+/)[0];
                if (!fs.existsSync(path.join(skill.dir, rel))) {
                    rep.error(`${name}: referenced path '${tok}' does not exist`);
                }
            }
        }
    }
}

function checkExternalTable(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError || skill.externalIndex === null) continue;
        if (skill.externalRows.length === 0) {
            rep.error(`${name}: '## External' section has no rows`);
            continue;
        }
        for (const row of skill.externalRows) {
            if (row.cells < 3) {
                rep.error(`${name}: External row '${row.path}' is malformed (need Path | Load | Read when)`);
                continue;
            }
            if (!row.path) {
                rep.error(`${name}: External row has an empty Path`);
            }
            if (!['required', 'on-demand'].includes(row.load)) {
                rep.error(`${name}: External '${row.path}' has load '${row.load}' (must be required|on-demand)`);
            }
            if (row.load === 'on-demand') {
                const trig = row.trigger.trim().toLowerCase().replace(/\.$/, '');
                if (TRIVIAL_TRIGGERS.has(trig) || trig.length < 8) {
                    rep.error(`${name}: External on-demand '${row.path}' needs a concrete 'Read when' trigger`);
                }
            }
        }
    }
}

function checkCardSync(skills, root, rep) {
    const owners = [];
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        const start = skill.text.indexOf(CARD_START);
        const end = skill.text.indexOf(CARD_END);
        if (start === -1 && end === -1) continue;
        if (start === -1 || end === -1 || end < start) {
            rep.error(`${name}: card markers unbalanced (${CARD_START} / ${CARD_END})`);
            continue;
        }
        owners.push([name, skill.text.slice(start + CARD_START.length, end).trim()]);
    }
    if (owners.length > 1) {
        rep.error(`card markers in more than one skill: ${owners.map(([n]) => n).join(', ')}`);
    }
    if (owners.length === 0) return;
    const [owner, card] = owners[0];
    for (const rel of ['.opencode/agents/orchestrator.md', '.opencode/skills/agent-delegation/assets/delegation-brief.template.md']) {
        const p = path.join(root, rel);
        if (!fs.existsSync(p)) {
            rep.error(`card sync: '${rel}' not found (owner '${owner}')`);
            continue;
        }
        const text = readText(p);
        if (!text.includes(card)) {
            rep.error(`card sync: '${rel}' does not contain the card from '${owner}' — re-copy it`);
        }
    }
}

function computeClosures(skills, rep) {
    const closures = new Map();
    for (const [name] of skills) {
        const order = [];
        const seen = new Set();
        let cycle = false;
        const walk = (node, pathSet) => {
            const skill = skills.get(node);
            if (!skill) return;
            for (const t of skill.loads) {
                if (!skills.has(t)) continue;
                if (pathSet.has(t)) {
                    cycle = true;
                    return;
                }
                if (seen.has(t)) continue;
                seen.add(t);
                order.push(t);
                const next = new Set(pathSet);
                next.add(t);
                walk(t, next);
            }
        };
        walk(name, new Set([name]));
        if (cycle) rep.error(`${name}: Loads cycle detected`);
        closures.set(name, order);
    }
    for (const [name, order] of closures) {
        if (order.length > MAX_CLOSURE) {
            rep.error(`${name}: transitive Loads closure is ${order.length} (> ${MAX_CLOSURE}): ${order.join(', ')}`);
        }
    }
    return closures;
}

function checkSizes(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        const budgetBytes = skill.bytes - metadataBytes(skill);
        const overDefault = skill.nlines > DEFAULT_MAX_LINES || budgetBytes > DEFAULT_MAX_BYTES;
        if (budgetBytes > HARD_MAX_BYTES) {
            rep.error(`${name}: SKILL.md is ${budgetBytes} B (> hard cap ${HARD_MAX_BYTES} B)`);
            continue;
        }
        if (overDefault) {
            const entry = BUDGET_EXCEPTIONS[name];
            if (!entry) {
                rep.error(
                    `${name}: SKILL.md over the default budget (${skill.nlines} lines, ${budgetBytes} B) and not a recorded exception`,
                );
                continue;
            }
            const { max_kb: maxKb, reason } = entry;
            if (typeof maxKb !== 'number' || maxKb > 32 || !reason) {
                rep.error(`${name}: budget exception needs a numeric max_kb (<= 32) and a reason`);
                continue;
            }
            if (budgetBytes > maxKb * 1024) {
                rep.error(`${name}: SKILL.md is ${budgetBytes} B (> max_kb ${maxKb} KB)`);
            } else {
                rep.warn(`${name}: SKILL.md over default budget (${skill.nlines} lines, ${budgetBytes} B) — recorded exception (${maxKb} KB)`);
            }
        }
        const total = reportBytes(skill);
        const totalEntry = BUDGET_EXCEPTIONS[name];
        const totalAllowed = totalEntry ? Math.min(totalEntry.max_kb * 1024, HARD_MAX_BYTES) : DEFAULT_MAX_BYTES;
        if (total > HARD_MAX_BYTES) {
            rep.error(`${name}: total load (SKILL.md + required files) is ${total} B (> ${HARD_MAX_BYTES} B hard cap)`);
        } else if (total > totalAllowed) {
            rep.error(`${name}: total load (SKILL.md + required files) is ${total} B (> ${totalAllowed} B)`);
        }
    }
    for (const [name, entry] of Object.entries(BUDGET_EXCEPTIONS)) {
        const skill = skills.get(name);
        if (!skill) {
            rep.error(`BUDGET_EXCEPTIONS: '${name}' is not a skill`);
            continue;
        }
        if (skill.parseError) continue;
        const budgetBytes = skill.bytes - metadataBytes(skill);
        if (skill.nlines <= DEFAULT_MAX_LINES && budgetBytes <= DEFAULT_MAX_BYTES) {
            rep.error(`BUDGET_EXCEPTIONS: '${name}' is within the default budget — remove the exception`);
        }
    }
}

function parseMatrix(skill) {
    const rows = [];
    if (skill.parseError) return rows;
    const lines = skill.lines;
    const mask = fenceMask(lines);
    let start = null;
    for (let i = 0; i < lines.length; i++) {
        if (mask[i]) continue;
        if (/^\s*\|\s*Task\s*\|\s*Governing skills\s*\|/.test(lines[i])) {
            start = i;
            break;
        }
    }
    if (start === null) return rows;
    let i = start + 2;
    while (i < lines.length) {
        const line = lines[i];
        if (mask[i] || !line.trim().startsWith('|')) break;
        const cells = line.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length >= 2) rows.push({ task: cells[0], cell: cells[1] });
        i++;
    }
    return rows;
}

function partParent(skills, name) {
    const skill = skills.get(name);
    if (!skill) return null;
    const m = skill.description.match(/Part of `([a-z0-9-]+)`/);
    return m ? m[1] : null;
}

function isPart(skills, name) {
    if (partParent(skills, name)) return true;
    for (const [pname, pskill] of skills) {
        if (pskill.parseError || name === pname) continue;
        if (!name.startsWith(pname + '-')) continue;
        if (findHeading(pskill.lines, fenceMask(pskill.lines), 'Parts') !== null) return true;
    }
    return false;
}

function parsePartsTable(skill, partsIndex) {
    const lines = skill.lines;
    const mask = fenceMask(lines);
    const end = sectionEnd(lines, mask, partsIndex);
    const rows = [];
    for (let i = partsIndex + 1; i < end; i++) {
        if (mask[i]) continue;
        const line = lines[i].trim();
        if (!line.startsWith('|')) continue;
        const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length < 3) continue;
        const first = cells[0].replace(/`/g, '').trim();
        if (['part', ''].includes(first.toLowerCase()) || [...first].every((c) => '-: '.includes(c))) continue;
        rows.push({ part: first, required: cells[2].replace(/`/g, '').trim().toLowerCase() === 'required' });
    }
    return rows;
}

function checkMatrix(skills, rep) {
    const matrixSkill = skills.get(MATRIX_SKILL);
    if (!matrixSkill) {
        rep.error(`${MATRIX_SKILL}: routing-matrix skill not found`);
        return;
    }
    const rows = parseMatrix(matrixSkill);
    if (!rows.length) {
        rep.error(`${MATRIX_SKILL}: routing matrix not found or unparseable`);
        return;
    }
    const named = new Set();
    for (const row of rows) {
        const cell = row.cell;
        const names = extractNames(cell);
        for (const n of names) {
            named.add(n);
            if (!skills.has(n)) rep.error(`matrix row '${row.task}': unknown skill '${n}'`);
        }
        if (!names.length) continue;
        const primary = names[0];
        if (cell.toLowerCase().includes('resolved from context')) continue;
        const group = cell.match(/\(([^)]*)\)/);
        if (group && (group[1].includes('+') || group[1].toLowerCase().includes('loads'))) {
            const comps = extractNames(group[1]);
            if (skills.has(primary)) {
                for (const c of comps) {
                    if (!skills.get(primary).loads.includes(c)) {
                        rep.error(
                            `matrix row '${row.task}': companion '${c}' not in '${primary}' Loads (or mark 'resolved from context')`,
                        );
                    }
                }
            }
        }
    }
    for (const name of [...skills.keys()].sort()) {
        if (named.has(name) || NON_MATRIX_ALLOWLIST[name]) continue;
        if (isPart(skills, name)) continue;
        rep.error(`${name}: not in the routing matrix and not in the non-matrix allowlist`);
    }
}

function checkParts(skills, rep) {
    for (const [name] of skills) {
        const parent = partParent(skills, name);
        if (parent && !skills.has(parent)) {
            rep.error(`${name}: declares 'Part of \`${parent}\`' but '${parent}' is not a skill`);
        }
    }
    const parents = [];
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        const idx = findHeading(skill.lines, fenceMask(skill.lines), 'Parts');
        if (idx !== null) parents.push([name, skill, idx]);
    }
    for (const [parent, pskill, partsIndex] of parents) {
        const onDisk = [...skills.keys()].filter((n) => n.startsWith(parent + '-')).sort();
        const table = parsePartsTable(pskill, partsIndex);
        const tableParts = table.map((r) => r.part);
        if (JSON.stringify([...tableParts].sort()) !== JSON.stringify(onDisk)) {
            rep.error(`${parent}: '## Parts' table [${tableParts}] != on-disk parts [${onDisk}]`);
        }
        const requiredParts = table.filter((r) => r.required).map((r) => r.part).sort();
        const loadedParts = pskill.loads.filter((n) => onDisk.includes(n)).sort();
        if (JSON.stringify(loadedParts) !== JSON.stringify(requiredParts)) {
            rep.error(`${parent}: Loads parts [${loadedParts}] != required parts [${requiredParts}]`);
        }
        for (const n of onDisk) {
            const prefix = `Part of \`${parent}\``;
            if (!skills.get(n).description.startsWith(prefix)) {
                rep.error(`${n}: description must begin "${prefix}: load via the parent only"`);
            }
            if (skills.get(n).loads.includes(parent)) {
                rep.error(`${n}: a part may not Load its parent '${parent}'`);
            }
        }
    }
    for (const [name, skill] of skills) {
        for (const p of walkFiles(skill.dir).filter((f) => path.basename(f) === 'SKILL.md')) {
            if (path.dirname(p) !== skill.dir) {
                rep.error(`${name}: nested SKILL.md at '${path.relative(skill.dir, p)}'`);
            }
        }
    }
    for (const [name, skill] of skills) {
        const partsDir = path.join(skill.dir, 'parts');
        if (!fs.existsSync(partsDir) || !fs.statSync(partsDir).isDirectory()) continue;
        if (!skill.text.slice(0, 400).includes('GENERATED')) {
            rep.error(`${name}: has parts/ sources but SKILL.md is not marked GENERATED`);
            continue;
        }
        const orderFile = path.join(partsDir, 'order.txt');
        const names = fs.existsSync(orderFile)
            ? readText(orderFile).split('\n').map((l) => l.trim()).filter(Boolean)
            : fs.readdirSync(partsDir).filter((f) => f.endsWith('.md')).sort();
        const combined = names
            .filter((n) => fs.existsSync(path.join(partsDir, n)))
            .map((n) => readText(path.join(partsDir, n)))
            .join('\n');
        if (combined.trim() && !skill.text.includes(combined.trim())) {
            rep.error(`${name}: generated SKILL.md is out of sync with parts/ sources`);
        }
    }
}

function checkProseDependencies(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError || skill.relatedIndex === null) continue;
        const mask = fenceMask(skill.lines);
        const end = sectionEnd(skill.lines, mask, skill.relatedIndex);
        const declared = new Set([...skill.loads, ...skill.references, name]);
        const mentioned = [];
        for (let i = 0; i < skill.lines.length; i++) {
            if (mask[i]) continue;
            if (i >= skill.relatedIndex && i < end) continue;
            if (skill.lines[i].trimStart().startsWith('|')) continue; // tables are structured data
            for (const tok of extractNames(skill.lines[i])) {
                if (skills.has(tok) && !declared.has(tok) && !mentioned.includes(tok)) mentioned.push(tok);
            }
        }
        for (const tok of mentioned) rep.warn(`${name}: body names '${tok}' but it is not in Related`);
    }
}

function checkNormativeReferences(skills, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        for (const row of skill.filesRows) {
            if (row.load !== 'on-demand' || !row.path.startsWith('references/')) continue;
            const p = path.join(skill.dir, row.path);
            if (!fs.existsSync(p) || !fs.statSync(p).isFile()) continue;
            const count = (readText(p).match(NORMATIVE_WORDS) || []).length;
            if (count >= NORMATIVE_WORD_THRESHOLD) {
                rep.warn(`${name}: on-demand '${row.path}' has ${count} normative statements — likely misclassified (should it be required?)`);
            }
        }
    }
}

function checkInbound(skills, rep) {
    const inbound = new Map([...skills.keys()].map((n) => [n, 0]));
    for (const [, skill] of skills) {
        if (skill.parseError) continue;
        for (const t of new Set([...skill.loads, ...skill.references])) {
            if (inbound.has(t)) inbound.set(t, inbound.get(t) + 1);
        }
    }
    for (const name of [...skills.keys()].sort()) {
        if (inbound.get(name) === 0 && !NON_MATRIX_ALLOWLIST[name]) {
            rep.warn(`${name}: zero inbound references`);
        }
    }
}

// --- Catalog migration checks (step 2: warn-only; they must not fail the build) ---

const CATALOG_CATEGORIES = new Set([
    'architecture', 'delivery', 'language', 'review', 'analysis', 'tooling', 'vault',
]);

function checkCatalogSchema(skills, rep) {
    let badCategory = 0;
    let missingRouteWhen = 0;
    for (const [, skill] of skills) {
        if (skill.parseError) continue;
        const meta = skill.frontmatter.metadata;
        const isMap = meta && typeof meta === 'object';
        const category = isMap ? meta.category : undefined;
        if (!CATALOG_CATEGORIES.has(category)) badCategory++;
        const routeWhen = isMap ? meta['route-when'] : undefined;
        if (!routeWhen || !String(routeWhen).trim()) missingRouteWhen++;
    }
    if (badCategory || missingRouteWhen) {
        rep.warn(`catalog schema: ${badCategory} skills missing/invalid category, ${missingRouteWhen} missing route-when`);
    }
}

/** Role-brief frontmatter: `governing` as an inline array or a block list. */
function parseRoleBriefGoverning(text) {
    if (!text.startsWith('---')) return { hasFrontmatter: false, governing: [] };
    const lines = text.split('\n');
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return { hasFrontmatter: false, governing: [] };
    const governing = [];
    let current = null;
    for (let i = 1; i < end; i++) {
        const dash = lines[i].match(/^\s*-\s+(.+?)\s*$/);
        if (dash && current === 'governing') {
            governing.push(unquoteScalar(dash[1]));
            continue;
        }
        const m = lines[i].match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
        if (!m) continue;
        current = m[1];
        if (m[1] !== 'governing') continue;
        const value = m[2].trim();
        if (value.startsWith('[') && value.endsWith(']')) {
            for (const s of value.slice(1, -1).split(',')) {
                const id = unquoteScalar(s.trim());
                if (id) governing.push(id);
            }
        } else if (value) {
            governing.push(unquoteScalar(value));
        }
    }
    return { hasFrontmatter: true, governing };
}

function checkRoleBriefs(skills, root, rep) {
    const dir = path.join(root, '.opencode', 'skills', 'agent-delegation', 'references', 'roles');
    if (!fs.existsSync(dir) || !fs.statSync(dir).isDirectory()) return;
    const entries = fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
    for (const e of entries) {
        if (!e.isFile() || !e.name.endsWith('.md')) continue;
        const parsed = parseRoleBriefGoverning(readText(path.join(dir, e.name)));
        if (!parsed.hasFrontmatter) continue;
        for (const id of parsed.governing) {
            if (!skills.has(id)) rep.warn(`role brief '${e.name}': unknown governing skill '${id}'`);
        }
    }
}

function checkCatalogStale(rep) {
    const script = path.join(HERE, 'build-catalog.mjs');
    if (!fs.existsSync(script)) return;
    const res = spawnSync(process.execPath, [script, '--check'], { encoding: 'utf8' });
    if (res.status !== 0) rep.warn('catalog is stale — run build-catalog.mjs');
}

/** The `permission.skill` allow-list keys in the orchestrator agent file. */
function orchestratorSkillAllowList(text) {
    if (!text.startsWith('---')) return [];
    const lines = text.split('\n');
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return [];
    const keys = [];
    let inPermission = false;
    let inSkill = false;
    for (let i = 1; i < end; i++) {
        const m = lines[i].match(/^(\s*)([A-Za-z0-9_./-]+):\s*(.*)$/);
        if (!m) continue;
        const indent = m[1].length;
        const key = m[2];
        if (indent === 0) {
            inPermission = key === 'permission';
            inSkill = false;
        } else if (inPermission && indent === 4) {
            inSkill = key === 'skill';
        } else if (inPermission && inSkill && indent >= 8) {
            keys.push(key);
        }
    }
    return keys;
}

function readCatalog(root) {
    const p = path.join(root, '.opencode', 'skills', 'catalog.json');
    if (!fs.existsSync(p)) return null;
    try {
        return JSON.parse(readText(p));
    } catch {
        return null;
    }
}

function checkAllowList(skills, root, rep) {
    const agentPath = path.join(root, '.opencode', 'agents', 'orchestrator.md');
    const catalog = readCatalog(root);
    if (!fs.existsSync(agentPath) || !catalog || !catalog.skills) return;
    const allow = orchestratorSkillAllowList(readText(agentPath));
    if (!allow.length) return;
    const allowSet = new Set(allow);
    const catalogSkills = Object.keys(catalog.skills).sort();
    const catalogSet = new Set(catalogSkills);
    const allowNotInCatalog = allow.filter((id) => !catalogSet.has(id));
    const catalogNotInAllow = catalogSkills.filter((id) => !allowSet.has(id));
    if (!allowNotInCatalog.length && !catalogNotInAllow.length) return;
    const parts = [];
    if (allowNotInCatalog.length) parts.push(`allow-listed but not in catalog: ${allowNotInCatalog.join(', ')}`);
    if (catalogNotInAllow.length) parts.push(`in catalog but not allow-listed: ${catalogNotInAllow.join(', ')}`);
    rep.warn(`skill allow-list drift — ${parts.join('; ')}`);
}

function checkGateDrift(root, rep) {
    const gatesPath = path.join(root, '.opencode', 'skills', 'jev-gates', 'assets', 'gates.json');
    const catalog = readCatalog(root);
    if (!fs.existsSync(gatesPath) || !catalog) return;
    let gates;
    try {
        gates = JSON.parse(readText(gatesPath));
    } catch {
        return;
    }
    const g = gates.gates || {};
    const matrixRows = catalog.matrixRows || [];
    const expectedMatrix = matrixRows.map((r) => r.task).sort();
    const gateMatrix = g.matrix_row && g.matrix_row.criteria ? Object.keys(g.matrix_row.criteria).sort() : [];
    if (JSON.stringify(expectedMatrix) !== JSON.stringify(gateMatrix)) {
        rep.warn('gate drift — matrix_row.criteria keys != catalog matrixRows tasks');
    }
    const expectedRoles = Object.keys(catalog.roles || {}).sort();
    const roleCriteria = g.role_routing && g.role_routing.criteria && g.role_routing.criteria.role
        ? g.role_routing.criteria.role.criteria || {}
        : {};
    const gateRoles = Object.keys(roleCriteria).sort();
    if (JSON.stringify(expectedRoles) !== JSON.stringify(gateRoles)) {
        rep.warn('gate drift — role_routing.criteria.role.criteria keys != catalog roles keys');
    }
}

// Skills whose SKILL.md must carry a generated block (and its markers).
const GENERATED_BLOCK_SKILLS = ['software-development', 'agent-delegation'];

/** The generated blocks must keep their `<!-- generated:start/end -->` markers. */
function checkGeneratedBlocks(skills, rep) {
    for (const name of GENERATED_BLOCK_SKILLS) {
        const skill = skills.get(name);
        if (!skill || skill.parseError) continue;
        if (!skill.text.includes('<!-- generated:start') || !skill.text.includes('<!-- generated:end')) {
            rep.warn(`${name}: missing generated-block markers (<!-- generated:start --> / <!-- generated:end -->)`);
        }
    }
}

function checkDiff(skills, root, base, rep) {
    for (const [name, skill] of skills) {
        if (skill.parseError) continue;
        const rel = path.relative(root, skill.path).split(path.sep).join('/');
        const baseText = gitShow(root, base, rel);
        if (baseText === null) continue; // new file
        const baseBytes = Buffer.byteLength(baseText, 'utf8');
        if (baseBytes === 0) continue;
        if (skill.bytes < baseBytes * 0.8) {
            const baseRows = new Set(parseFilesRowsFromText(baseText).map((r) => `${r.path}|${r.load}`));
            const curRows = new Set(skill.filesRows.map((r) => `${r.path}|${r.load}`));
            const same = baseRows.size === curRows.size && [...baseRows].every((r) => curRows.has(r));
            if (same) {
                const pct = Math.round((100 * (baseBytes - skill.bytes)) / baseBytes);
                rep.error(
                    `${name}: SKILL.md shrank by ${pct}% — if content moved to references/, declare it in ## Files and confirm it is lookup content, or mark it \`required\`.`,
                );
            } else {
                rep.warn(`${name}: SKILL.md shrank and the ## Files table changed — confirm the moved content is lookup, not normative`);
            }
        }
        const baseLines = baseText.split('\n').length;
        if (skill.nlines < baseLines) {
            const basePaths = new Set(parseFilesRowsFromText(baseText).map((r) => r.path));
            for (const row of skill.filesRows) {
                if (!basePaths.has(row.path) && row.load === 'on-demand') {
                    rep.warn(`${name}: new on-demand file '${row.path}' added while SKILL.md lost lines`);
                }
            }
        }
    }
}

function expandHome(p) {
    return p.startsWith('~/') ? path.join(os.homedir(), p.slice(2)) : p;
}

// The longest real path prefix of a possibly-globbed pointer, for existence.
function probePath(p) {
    const star = p.indexOf('*');
    const base = star === -1 ? p : p.slice(0, p.lastIndexOf('/', star) + 1);
    return expandHome(base);
}

function resolveTarget(skills, target) {
    const matrixSkill = skills.get(MATRIX_SKILL);
    let targets = [];
    if (skills.has(target)) {
        targets = [target];
    } else if (matrixSkill) {
        for (const row of parseMatrix(matrixSkill)) {
            if (row.task.toLowerCase().includes(target.toLowerCase())) {
                targets = extractNames(row.cell);
                console.log(`# matrix row: ${row.task.trim()}`);
                break;
            }
        }
    }
    if (!targets.length) {
        console.error(`resolve: no skill or matrix row matches '${target}'`);
        return 1;
    }
    const order = [];
    const seen = new Set();
    const walk = (node) => {
        if (seen.has(node)) return;
        seen.add(node);
        order.push(node);
        const skill = skills.get(node);
        if (skill) for (const t of skill.loads) if (skills.has(t)) walk(t);
    };
    for (const t of targets) walk(t);

    console.log('\n## Governing skills (Loads closure, in order)');
    for (const name of order) console.log(`  ${skills.get(name).path}`);

    console.log('\n## Required files');
    let anyFile = false;
    for (const name of order) {
        const skill = skills.get(name);
        for (const rel of requiredFiles(skill)) {
            console.log(`  ${path.join(skill.dir, rel)}`);
            anyFile = true;
        }
    }
    if (!anyFile) console.log('  (none)');

    console.log('\n## Required External pointers (hand these to the worker)');
    let anyExt = false;
    for (const name of order) {
        const skill = skills.get(name);
        for (const row of skill.externalRows) {
            if (row.load !== 'required') continue;
            const abs = probePath(row.path);
            const note = fs.existsSync(abs) ? '' : '  [MISSING on this machine]';
            console.log(`  ${abs}${note} — ${row.trigger}`);
            anyExt = true;
        }
    }
    if (!anyExt) console.log('  (none)');

    console.log('\n## On-demand (load only when the trigger fires)');
    let anyOn = false;
    for (const name of order) {
        const skill = skills.get(name);
        for (const row of skill.filesRows) {
            if (row.load !== 'on-demand') continue;
            console.log(`  ${path.join(skill.dir, row.path)} — ${row.trigger}`);
            anyOn = true;
        }
        for (const row of skill.externalRows) {
            if (row.load !== 'on-demand') continue;
            console.log(`  ${expandHome(row.path)} — ${row.trigger}`);
            anyOn = true;
        }
    }
    if (!anyOn) console.log('  (none)');
    return 0;
}

function printStats(skills) {
    const rep = new Report();
    const closures = computeClosures(skills, rep);
    let max = 0;
    let maxName = '';
    for (const [n, order] of closures) {
        if (order.length > max) {
            max = order.length;
            maxName = n;
        }
    }
    let req = 0;
    let on = 0;
    for (const [, skill] of skills) {
        for (const row of skill.filesRows) {
            if (row.load === 'required') req++;
            else if (row.load === 'on-demand') on++;
        }
    }
    let over = 0;
    const overList = [];
    for (const [n, skill] of skills) {
        if (skill.nlines > DEFAULT_MAX_LINES || skill.bytes > DEFAULT_MAX_BYTES) {
            over++;
            overList.push(`${n} (${skill.nlines}L, ${skill.bytes}B)`);
        }
    }
    console.log(`skills: ${skills.size}`);
    console.log(`max transitive Loads closure (excluding self): ${max} (${maxName})`);
    console.log(`required files: ${req} | on-demand files: ${on} | total declared files: ${req + on}`);
    console.log(`skills over default budget: ${over}${overList.length ? ' -> ' + overList.join('; ') : ''}`);
}

function parseArgs(argv) {
    const args = { root: null, base: null, resolve: null, quiet: false, errorsOnly: false, stats: false };
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--root') args.root = argv[++i];
        else if (a === '--base') args.base = argv[++i];
        else if (a === '--resolve') args.resolve = argv[++i];
        else if (a === '--quiet') args.quiet = true;
        else if (a === '--errors-only') args.errorsOnly = true;
        else if (a === '--stats') args.stats = true;
    }
    return args;
}

function main(argv) {
    const args = parseArgs(argv);
    const root = args.root ? path.resolve(args.root) : findRoot(HERE);
    if (!root || !fs.existsSync(path.join(root, '.opencode', 'skills'))) {
        console.error('lint-skills: could not locate .opencode/skills; pass --root <repo>');
        return 2;
    }
    const skills = discover(root);

    if (args.resolve) return resolveTarget(skills, args.resolve);
    if (args.stats) {
        printStats(skills);
        return 0;
    }

    const rep = new Report();
    checkFrontmatter(skills, rep);
    checkRelatedTargets(skills, rep);
    checkRelatedPosition(skills, rep);
    checkFilesTable(skills, rep);
    checkExternalTable(skills, rep);
    computeClosures(skills, rep);
    checkSizes(skills, rep);
    checkCardSync(skills, root, rep);
    checkMatrix(skills, rep);
    checkParts(skills, rep);
    checkProseDependencies(skills, rep);
    checkNormativeReferences(skills, rep);
    checkInbound(skills, rep);
    checkCatalogSchema(skills, rep);
    checkRoleBriefs(skills, root, rep);
    checkCatalogStale(rep);
    checkAllowList(skills, root, rep);
    checkGeneratedBlocks(skills, rep);
    checkGateDrift(root, rep);
    if (args.base) checkDiff(skills, root, args.base, rep);

    for (const w of rep.warnings) {
        if (!args.errorsOnly) console.log(`warning: ${w}`);
    }
    for (const e of rep.errors) console.log(`error: ${e}`);
    if (!args.quiet && !args.errorsOnly) {
        console.log(`\n${skills.size} skills; ${rep.errors.length} error(s), ${rep.warnings.length} warning(s)`);
    }
    return rep.errors.length ? 1 : 0;
}

process.exit(main(process.argv.slice(2)));
