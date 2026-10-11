#!/usr/bin/env node
/**
 * Audit the opencode skill library. Read-only; emits a markdown report to
 * stdout. Where `lint-skills.mjs` enforces the hard rules, this is the
 * diagnostic you run before and after a refactor.
 *
 * Modes:
 *   --pointers              declared files (size + normative count), on-demand
 *                           files under 2 KB, rule-behind-a-pointer sentences,
 *                           cross-skill file dependencies, prose deferrals to
 *                           skills not in Loads, undeclared external pointers.
 *   --generic               project-specific smells: dated anecdotes, incident
 *                           narrative, project names (configurable).
 *   --rules <skill-dir>     one line per normative statement (heading path,
 *                           normalised text, short hash).
 *   --diff-rules <old> <new>
 *                           normative statements in <old> but absent from <new>
 *                           (normalised; moved headings ignored).
 *
 * With no mode, runs --pointers and --generic over the whole library.
 *
 * Node standard library only. Deterministic output. Exit 0 even when findings
 * exist (it is a report, not a gate); exit 2 on a usage error.
 *
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/audit-skills.mjs --pointers
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/audit-skills.mjs --generic
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/audit-skills.mjs --rules .opencode/skills/software-architecture
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/audit-skills.mjs --diff-rules <old-dir> <new-dir>
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const KB = 1024;
const MIN_REFERENCE_BYTES = 2 * KB; // the inline-by-default floor
const MAX_REQUIRED_BYTES = 8 * KB; // a required file over this is a skill

const FILES_DIRS = ['references', 'assets', 'scripts'];
// Role briefs (passed to a worker by path) and assets (templates) are exempt
// from the 2 KB floor; the floor governs knowledge references only. Scripts are
// run, not read, so they are exempt from both the floor and the 8 KB ceiling.
const REFERENCE_FLOOR_EXEMPT = [/^references\/roles\//, /^scripts\//, /^assets\//];

// Normative signals. Uppercase keywords are unambiguous; lowercase words are
// counted case-insensitively but only as whole words.
const NORMATIVE_RE =
    /\b(MUST|NEVER|REQUIRED|ALWAYS|SHALL)\b|\b(must|never|always|required)\b|is a defect/gi;

// Sentences that make a rule depend on a file the reader may never open.
const RULE_BEHIND_POINTER_RE =
    /(full detail|for details see\s+`(references|assets)\/[^`]+`|see\s+`(references|assets)\/[^`]+`|(?:lives?|are|is)\s+in\s+`(references|assets)\/[^`]+`|documented in\s+`(references|assets)\/[^`]+`)/gi;

// Prose deferrals to another skill (strong signals only — a skill that must be
// loaded because this skill's body defers a rule to it).
const DEFERRAL_WORDS_RE =
    /(single[- ]sourced|single source of truth|`[a-z0-9-]+`\s+owns\b|owns (?:the|this)|see\s+`[a-z0-9-]+`\s+for the (?:contract|rule|procedure|method)|(?:the|its) (?:contract|rule|rules) (?:is|are|for|lives)|defined in\s+`[a-z0-9-]+`|specified in\s+`[a-z0-9-]+`|defer to\s+`[a-z0-9-]+`)/i;

// Project-name smells. User-wide repo families are never flagged.
const FAMILY_RE = [
    /-skeleton$/,
    /-module-/,
    /^devshell-/,
    /^docker-/,
    /^kubernetes-/,
    /^git-skeleton$/,
    /^home-manager$/,
    /^nixos-config$/,
    /^opencode-/,
    /^99linesofcode-/,
    /^hermes-agent$/,
    /^tauri-app$/,
    /^\./, // dot-directories: .github, .github-php, .git, ...
    /^node_modules$/,
];
const DEFAULT_PROJECT_NAMES = ['OPM', 'Todoist', 'GithubTaskData', 'TodoistTaskData', 'obsidian-project-management'];

const INCIDENT_RE = [
    /found in exactly that state/i,
    /\bworked example\b/i,
    /was found\b/i,
    /were found\b/i,
    /shipped (?:through|while)/i,
    /caught by the user/i,
    /misdiagnos/i,
    /the (?:rogue|leaked) /i,
    /followed;? the .* bug/i,
    /the bug\b/i,
    /regression\b/i,
];
const DATED_RE = /\((?:19|20)\d{2}-\d{2}-\d{2}|\b(?:19|20)\d{2}-\d{2}-\d{2}\)|\b(?:19|20)\d{2}-\d{2}-\d{2}\b/;

// ---------------------------------------------------------------- helpers

function readText(p) {
    return fs.readFileSync(p, 'utf8');
}

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

function walkFiles(dir) {
    const out = [];
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        if (e.isDirectory()) out.push(...walkFiles(p));
        else if (e.isFile()) out.push(p);
    }
    return out;
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

function sectionEnd(lines, mask, start) {
    for (let i = start + 1; i < lines.length; i++) {
        if (!mask[i] && lines[i].startsWith('## ')) return i;
    }
    return lines.length;
}

function headingPath(lines, mask, upto) {
    const stack = [];
    for (let i = 0; i <= upto && i < lines.length; i++) {
        if (mask[i]) continue;
        const m = lines[i].match(/^(#{1,6})\s+(.*)$/);
        if (m) {
            const level = m[1].length;
            stack.length = level - 1;
            stack[level - 1] = m[2].trim();
        }
    }
    return stack.filter(Boolean).join(' > ');
}

function normalise(text) {
    return text
        .replace(/`/g, '')
        .replace(/\*\*|\*|__|_/g, '')
        .replace(/^\s*[-*+]\s+/, '')
        .replace(/^\s*\d+\.\s+/, '')
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase();
}

function shortHash(text) {
    let h = 2166136261;
    for (let i = 0; i < text.length; i++) {
        h ^= text.charCodeAt(i);
        h = Math.imul(h, 16777619);
    }
    return (h >>> 0).toString(16).padStart(8, '0');
}

function parseTable(skill, headingTitle) {
    const lines = skill.lines;
    const mask = fenceMask(lines);
    let start = null;
    for (let i = 0; i < lines.length; i++) {
        if (!mask[i] && lines[i].trim() === `## ${headingTitle}`) {
            start = i;
            break;
        }
    }
    const rows = [];
    if (start === null) return rows;
    const end = sectionEnd(lines, mask, start);
    for (let i = start + 1; i < end; i++) {
        if (mask[i]) continue;
        const line = lines[i].trim();
        if (!line.startsWith('|')) continue;
        const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length < 2) continue;
        const first = cells[0].replace(/`/g, '').trim();
        if (['file', 'path', ''].includes(first.toLowerCase()) || [...first].every((c) => '-: '.includes(c))) continue;
        rows.push(cells);
    }
    return rows;
}

function parseRelated(skill) {
    const lines = skill.lines;
    const mask = fenceMask(lines);
    let start = null;
    for (let i = 0; i < lines.length; i++) {
        if (!mask[i] && lines[i].trim() === '## Related') {
            start = i;
            break;
        }
    }
    skill.loads = [];
    skill.references = [];
    if (start === null) return;
    const end = sectionEnd(lines, mask, start);
    skill.relatedRange = [start, end];
    let current = null;
    for (let i = start + 1; i < end; i++) {
        const line = lines[i];
        const m = line.match(/\s*-\s*\*\*(Loads|References):\*\*(.*)/);
        if (m) {
            current = m[1].toLowerCase();
            const value = m[2];
            const names = value.trim().replace(/^\(/, '').toLowerCase().startsWith('none')
                ? []
                : (value.match(/`([a-z0-9-]+)`/g) || []).map((s) => s.replace(/`/g, ''));
            for (const n of names) (current === 'loads' ? skill.loads : skill.references).push(n);
            continue;
        }
        if (line.trimStart().startsWith('- ')) current = null;
    }
}

function loadSkill(dir) {
    const p = path.join(dir, 'SKILL.md');
    if (!fs.existsSync(p)) return null;
    const text = readText(p);
    const lines = text.split('\n');
    const mask = fenceMask(lines);
    const skill = {
        name: path.basename(dir),
        dir,
        path: p,
        text,
        lines,
        mask,
        bytes: fs.statSync(p).size,
        filesRows: [],
        externalRows: [],
        physicalFiles: [],
        loads: [],
        references: [],
        fmEnd: -1,
        relatedRange: null,
    };
    if (lines[0] && lines[0].trim() === '---') {
        for (let i = 1; i < lines.length; i++) {
            if (lines[i].trim() === '---') {
                skill.fmEnd = i;
                break;
            }
        }
    }
    for (const cells of parseTable(skill, 'Files')) {
        skill.filesRows.push({ path: cells[0].replace(/`/g, '').trim(), load: (cells[1] || '').replace(/`/g, '').trim().toLowerCase(), trigger: (cells[2] || '').trim() });
    }
    for (const cells of parseTable(skill, 'External')) {
        skill.externalRows.push({ path: cells[0].replace(/`/g, '').trim(), load: (cells[1] || '').replace(/`/g, '').trim().toLowerCase(), trigger: (cells[2] || '').trim() });
    }
    parseRelated(skill);
    for (const f of walkFiles(dir).sort()) {
        const rel = path.relative(dir, f).split(path.sep).join('/');
        if (FILES_DIRS.includes(rel.split('/')[0])) skill.physicalFiles.push(rel);
    }
    return skill;
}

function discover(root) {
    const skillsDir = path.join(root, '.opencode', 'skills');
    const out = new Map();
    for (const e of fs.readdirSync(skillsDir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
        if (!e.isDirectory()) continue;
        const s = loadSkill(path.join(skillsDir, e.name));
        if (s) out.set(s.name, s);
    }
    return out;
}

function normativeCount(text) {
    return (text.match(NORMATIVE_RE) || []).length;
}

// Rows in a table whose enclosing section mentions "closed" (the closed menus).
function closedMenuRows(skill) {
    let count = 0;
    for (let i = 0; i < skill.lines.length; i++) {
        if (skill.mask[i]) continue;
        if (!skill.lines[i].trim().startsWith('|')) continue;
        const line = skill.lines[i].trim();
        if ([...line.replace(/\|/g, '')].every((c) => '-: '.includes(c))) continue;
        const context = skill.lines.slice(Math.max(0, i - 6), i).join(' ');
        if (/\bclosed\b/i.test(context)) count++;
    }
    return count;
}

function isFloorExempt(rel) {
    return REFERENCE_FLOOR_EXEMPT.some((re) => re.test(rel));
}

function expandHome(p) {
    return p.startsWith('~/') ? path.join(os.homedir(), p.slice(2)) : p;
}

// ------------------------------------------------------------- --pointers

function auditPointers(root, skills) {
    const out = [];
    out.push('# Audit — pointers\n');
    out.push(`Library root: \`${root}\`\n`);

    // Cross-skill file ownership map.
    const owner = new Map();
    for (const [, s] of skills) {
        for (const rel of s.physicalFiles) owner.set(rel, s.name);
    }

    let totals = { smallOnDemand: 0, bigRequired: 0, behindPointer: 0, crossSkill: 0, deferrals: 0, external: 0 };

    for (const [name, s] of skills) {
        const lines = [];
        for (const row of s.filesRows) {
            const p = path.join(s.dir, row.path);
            const exists = fs.existsSync(p) && fs.statSync(p).isFile();
            const size = exists ? fs.statSync(p).size : 0;
            const norm = exists ? normativeCount(readText(p)) : 0;
            let flag = '';
            if (row.load === 'on-demand' && exists && size < MIN_REFERENCE_BYTES && !isFloorExempt(row.path)) {
                flag = ' ← UNDER 2 KB (inline it)';
                totals.smallOnDemand++;
            }
            if (row.load === 'required' && exists && size > MAX_REQUIRED_BYTES && !isFloorExempt(row.path)) {
                flag = ' ← REQUIRED OVER 8 KB (promote to a skill)';
                totals.bigRequired++;
            }
            lines.push(`  - \`${row.path}\` [${row.load}] ${size} B, ${norm} normative${flag}`);
        }

        // (c) rule-behind-a-pointer sentences in SKILL.md. A pointer to a
        // `required` file, or to a skill in `Loads`, is not a defect.
        const behind = [];
        for (let i = 0; i < s.lines.length; i++) {
            if (s.mask[i]) continue;
            const line = s.lines[i];
            RULE_BEHIND_POINTER_RE.lastIndex = 0;
            if (!RULE_BEHIND_POINTER_RE.test(line)) continue;
            const fileM = line.match(/`((?:references|assets|scripts)\/[^`]+)`/);
            let satisfied = false;
            if (fileM) {
                const rel = fileM[1].split(/\s+/)[0];
                const row = s.filesRows.find((r) => r.path === rel);
                if (row && row.load === 'required') satisfied = true;
            }
            if (!satisfied) {
                for (const tok of line.match(/`([a-z0-9-]+)`/g) || []) {
                    if (s.loads.includes(tok.replace(/`/g, ''))) {
                        satisfied = true;
                        break;
                    }
                }
            }
            if (!satisfied) behind.push(line.trim());
        }
        for (const b of behind) totals.behindPointer++;

        // (d) cross-skill file dependencies (a backticked path owned by another
        // skill, outside fenced examples).
        const cross = [];
        for (const [rel, ownerName] of owner) {
            if (ownerName === name) continue;
            const needle = '`' + rel + '`';
            for (let i = 0; i < s.lines.length; i++) {
                if (s.mask[i]) continue;
                if (s.lines[i].includes(needle)) {
                    cross.push(`${rel} (owned by ${ownerName})`);
                    break;
                }
            }
        }
        for (const c of cross) totals.crossSkill++;

        // (e) prose deferrals to a skill not in Loads.
        const deferrals = [];
        for (let i = 0; i < s.lines.length; i++) {
            if (s.mask[i] || i <= s.fmEnd) continue;
            if (s.relatedRange && i >= s.relatedRange[0] && i < s.relatedRange[1]) continue;
            const line = s.lines[i];
            const names = (line.match(/`([a-z0-9-]+)`/g) || []).map((x) => x.replace(/`/g, ''));
            const referenced = names.filter((n) => skills.has(n) && n !== name);
            if (!referenced.length) continue;
            if (!DEFERRAL_WORDS_RE.test(line)) continue;
            for (const n of referenced) {
                if (!s.loads.includes(n)) deferrals.push(`\`${n}\` — ${line.trim()}`);
            }
        }
        const seenDefer = new Set();
        const uniqDefer = deferrals.filter((d) => (seenDefer.has(d) ? false : (seenDefer.add(d), true)));
        for (const d of uniqDefer) totals.deferrals++;

        // (f) undeclared external pointers.
        const declared = s.externalRows.map((r) => r.path);
        const externals = [];
        const clean = (t) => t.replace(/[.,:;)\]]+$/, '').replace(/\/+$/, '');
        for (let i = 0; i < s.lines.length; i++) {
            if (s.mask[i] || i <= s.fmEnd) continue;
            const line = s.lines[i];
            const tokens = (line.match(/~\/Development\/[^\s`)"']+|~\/Documents\/[^\s`)"']+/g) || [])
                .filter((t) => !/[<>]/.test(t))
                .map(clean);
            for (const t of tokens) {
                if (declared.some((d) => t.startsWith(clean(d)) || clean(d).startsWith(t))) continue;
                externals.push(t);
            }
            if (/reference repos?\b/i.test(line) && !declared.length) externals.push('reference repos');
            if (/\bmirror the reference\b/i.test(line) && !declared.length) externals.push('mirror the reference');
        }
        const seenExt = new Set();
        const uniqExt = externals.filter((d) => (seenExt.has(d) ? false : (seenExt.add(d), true)));
        for (const e of uniqExt) totals.external++;

        const hasFindings = lines.length || behind.length || cross.length || uniqDefer.length || uniqExt.length;
        if (!hasFindings) continue;
        out.push(`## ${name}\n`);
        if (lines.length) {
            out.push('**Declared files**');
            out.push(...lines);
        }
        if (behind.length) {
            out.push('\n**Rule behind a pointer**');
            for (const b of behind) out.push(`  - ${b}`);
        }
        if (cross.length) {
            out.push('\n**Cross-skill file dependency**');
            for (const c of cross) out.push(`  - ${c}`);
        }
        if (uniqDefer.length) {
            out.push('\n**Prose deferral to a skill not in Loads**');
            for (const d of uniqDefer) out.push(`  - ${d}`);
        }
        if (uniqExt.length) {
            out.push('\n**Undeclared external pointer**');
            for (const e of uniqExt) out.push(`  - \`${e}\``);
        }
        out.push('');
    }

    out.push('## Totals\n');
    out.push(`- on-demand knowledge references under 2 KB: ${totals.smallOnDemand}`);
    out.push(`- required files over 8 KB: ${totals.bigRequired}`);
    out.push(`- rule-behind-a-pointer sentences: ${totals.behindPointer}`);
    out.push(`- cross-skill file dependencies: ${totals.crossSkill}`);
    out.push(`- prose deferrals to a skill not in Loads: ${totals.deferrals}`);
    out.push(`- undeclared external pointers: ${totals.external}`);
    return out.join('\n');
}

// -------------------------------------------------------------- --generic

function discoverProjectNames() {
    const names = new Set(DEFAULT_PROJECT_NAMES);
    const dev = path.join(os.homedir(), 'Development');
    if (fs.existsSync(dev)) {
        for (const e of fs.readdirSync(dev, { withFileTypes: true })) {
            if (!e.isDirectory()) continue;
            if (FAMILY_RE.some((re) => re.test(e.name))) continue;
            names.add(e.name);
        }
    }
    return [...names];
}

function auditGeneric(skills, projectNames, includeIncident) {
    const out = [];
    out.push('# Audit — generic vs project-specific\n');
    out.push(`Project names watched: ${projectNames.map((n) => `\`${n}\``).join(', ')}\n`);
    const nameRes = projectNames.map((n) => new RegExp(`(^|[^A-Za-z0-9-])${n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}([^A-Za-z0-9-]|$)`));

    let dated = 0;
    let worked = 0;
    let incident = 0;
    let names = 0;
    for (const [name, s] of skills) {
        const lines = [];
        for (let i = 0; i < s.lines.length; i++) {
            if (s.mask[i]) continue;
            const line = s.lines[i];
            const hits = [];
            // A "Verified against X (date)" stamp is provenance, not a dated anecdote.
            if (DATED_RE.test(line) && !/verified/i.test(line)) hits.push('dated');
            if (/\bworked example\b/i.test(line)) hits.push('worked-example');
            if (includeIncident && INCIDENT_RE.some((re) => re.test(line))) hits.push('incident');
            for (const re of nameRes) if (re.test(line)) hits.push('project-name');
            if (!hits.length) continue;
            const uniq = [...new Set(hits)];
            if (uniq.includes('dated')) dated++;
            if (uniq.includes('worked-example')) worked++;
            if (uniq.includes('incident')) incident++;
            if (uniq.includes('project-name')) names++;
            lines.push(`  - [${uniq.join(', ')}] ${line.trim()}`);
        }
        if (!lines.length) continue;
        out.push(`## ${name}\n`);
        out.push(...lines);
        out.push('');
    }
    out.push('## Totals\n');
    out.push(`- dated anecdotes: ${dated}`);
    out.push(`- worked examples: ${worked}`);
    out.push(`- incident narrative lines: ${incident}`);
    out.push(`- project-name lines: ${names}`);
    return out.join('\n');
}

// ---------------------------------------------------------- --rules / diff

function collectRuleFiles(dir) {
    const files = [];
    const skill = path.join(dir, 'SKILL.md');
    if (fs.existsSync(skill)) files.push(skill);
    for (const sub of ['references', 'assets']) {
        const d = path.join(dir, sub);
        if (fs.existsSync(d)) files.push(...walkFiles(d).sort());
    }
    return files;
}

function extractRules(file) {
    const text = readText(file);
    const lines = text.split('\n');
    const mask = fenceMask(lines);
    // A "statement" is a logical block: a paragraph, a list item (with its
    // wrapped continuation lines), or a table row. Joining wrapped lines makes
    // the inventory and the diff robust to re-wrapping.
    const blocks = [];
    let buf = [];
    let heading = '';
    const flush = () => {
        if (buf.length) {
            blocks.push({ heading, text: buf.join(' ') });
            buf = [];
        }
    };
    for (let i = 0; i < lines.length; i++) {
        if (mask[i]) continue;
        const line = lines[i];
        if (!line.trim()) {
            flush();
            continue;
        }
        if (/^#{1,6}\s/.test(line)) {
            flush();
            heading = headingPath(lines, mask, i);
            continue;
        }
        if (line.trim().startsWith('|')) {
            flush();
            blocks.push({ heading, text: line.trim() });
            continue;
        }
        if (/^\s*([-*+]|\d+\.)\s/.test(line)) {
            flush();
            heading = headingPath(lines, mask, i);
            buf.push(line.trim());
            continue;
        }
        buf.push(line.trim());
    }
    flush();

    const rules = [];
    for (const b of blocks) {
        NORMATIVE_RE.lastIndex = 0;
        if (!NORMATIVE_RE.test(b.text)) continue;
        const norm = normalise(b.text);
        if (!norm) continue;
        rules.push({ heading: b.heading, text: norm, hash: shortHash(norm), raw: b.text });
    }
    return rules;
}

function auditRules(dir) {
    const out = [];
    out.push(`# Rules — ${dir}\n`);
    for (const file of collectRuleFiles(dir)) {
        const rules = extractRules(file);
        out.push(`## ${path.relative(dir, file) || path.basename(file)} (${rules.length})\n`);
        for (const r of rules) out.push(`- [${r.hash}] ${r.heading} :: ${r.text}`);
        out.push('');
    }
    return out.join('\n');
}

function diffRules(oldDir, newDir) {
    const oldRules = [];
    for (const f of collectRuleFiles(oldDir)) oldRules.push(...extractRules(f));
    const newSet = new Set();
    for (const f of collectRuleFiles(newDir)) for (const r of extractRules(f)) newSet.add(r.text);
    const out = [];
    out.push(`# Rule diff — ${oldDir} → ${newDir}\n`);
    const missing = oldRules.filter((r) => !newSet.has(r.text));
    out.push(`Old normative statements: ${oldRules.length}`);
    out.push(`New normative statements: ${[...newSet].length}`);
    out.push(`Missing from new: ${missing.length}\n`);
    for (const r of missing) out.push(`- [${r.hash}] ${r.heading} :: ${r.text}`);
    return out.join('\n');
}

// ------------------------------------------------------------------ main

function parseArgs(argv) {
    const args = { pointers: false, generic: false, rules: null, diff: null, root: null, projects: null, noDiscover: false, noIncident: false };
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--pointers') args.pointers = true;
        else if (a === '--generic') args.generic = true;
        else if (a === '--rules') args.rules = argv[++i];
        else if (a === '--diff-rules') args.diff = [argv[++i], argv[++i]];
        else if (a === '--root') args.root = argv[++i];
        else if (a === '--projects') args.projects = argv[++i].split(',').map((s) => s.trim()).filter(Boolean);
        else if (a === '--no-discover') args.noDiscover = true;
        else if (a === '--no-incident') args.noIncident = true;
    }
    return args;
}

function main(argv) {
    const args = parseArgs(argv);

    if (args.rules) {
        process.stdout.write(auditRules(path.resolve(args.rules)) + '\n');
        return 0;
    }
    if (args.diff) {
        process.stdout.write(diffRules(path.resolve(args.diff[0]), path.resolve(args.diff[1])) + '\n');
        return 0;
    }

    const root = args.root ? path.resolve(args.root) : findRoot(HERE);
    if (!root || !fs.existsSync(path.join(root, '.opencode', 'skills'))) {
        console.error('audit-skills: could not locate .opencode/skills; pass --root <repo>');
        return 2;
    }
    const skills = discover(root);
    const runBoth = !args.pointers && !args.generic;

    if (args.pointers || runBoth) process.stdout.write(auditPointers(root, skills) + '\n');
    if (args.generic || runBoth) {
        const names = args.projects || (args.noDiscover ? DEFAULT_PROJECT_NAMES : discoverProjectNames());
        process.stdout.write(auditGeneric(skills, names, !args.noIncident) + '\n');
    }
    return 0;
}

process.exit(main(process.argv.slice(2)));
