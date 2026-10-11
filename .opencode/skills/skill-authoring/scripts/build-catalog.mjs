#!/usr/bin/env node
/**
 * Build the skill catalog at `.opencode/skills/catalog.json`.
 *
 * The catalog file is a GENERATED artifact — do not hand-edit it; run this
 * script instead.
 *
 * It parses, per skill directory under `.opencode/skills/<id>/SKILL.md`: the
 * frontmatter `name`, the nested `metadata` keys (`category`, `route-when`,
 * `route-not-when`), the `description` and its first-sentence `summary`, the
 * `## Related` graph (`loads` / `references`), the `## Files` table
 * (`tier`: required | on-demand), and the `## External` table. It also parses
 * each role brief under `agent-delegation/references/roles/*.md` for
 * `role` / `governing` / `context-resolved` / `route-when`.
 *
 * It also renders the derived artifacts from that catalog: the routing matrix
 * in `software-development` and the task→role / role→governing tables in
 * `agent-delegation` (between generated-block markers), the two Jev gate
 * option sets in `jev-gates/assets/gates.json`, and the derived half of
 * `skills/tree.json` (`branches` and `leaves`; its `crossCutting` and
 * `progressiveDisclosure` are hand-authored and preserved). `--check` compares
 * all of them, except the authored half of `tree.json`.
 *
 * Determinism is mandatory: all keys and arrays are sorted and no timestamps
 * or absolute paths are emitted, so two runs on the same tree are
 * byte-identical.
 *
 * Usage:
 *   node build-catalog.mjs             write catalog.json, both SKILL.md
 *                                      blocks, gates.json, and the derived
 *                                      half of tree.json
 *   node build-catalog.mjs --check     exit non-zero if any committed artifact differs
 *
 * Node standard library only. The library root is found by walking up from this
 * file for `.opencode/skills`. Run it from the repository root (no node on PATH
 * needed on NixOS):
 *   nix run nixpkgs#nodejs_22 -- .opencode/skills/skill-authoring/scripts/build-catalog.mjs
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SCHEMA = 1;
const SUMMARY_MAX = 160;
const HERE = path.dirname(fileURLToPath(import.meta.url));

// Skills deliberately outside the software-development routing matrix, mirroring
// lint-skills.mjs's NON_MATRIX_ALLOWLIST. Keep the two lists in sync.
const NON_MATRIX_ALLOWLIST = new Set([
    'memory',
    'wiki',
    'vault-notes',
    'teach-mode',
    'communication-standards',
    'beeper-bridge',
    'typst-document',
    'research-prompt-skills',
]);

// The generated-block markers. Three blocks are rendered: the routing matrix in
// `software-development`, and the task→role and role→governing tables in
// `agent-delegation`.
const START_MARKER = '<!-- generated:start — do not edit; regenerate with build-catalog.mjs -->';
const END_MARKER = '<!-- generated:end -->';

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

function unquote(value) {
    if (value.length >= 2 && value[0] === value[value.length - 1] && `"'\``.includes(value[0])) {
        return value.slice(1, -1);
    }
    return value;
}

/**
 * Split YAML frontmatter, mirroring `lint-skills.mjs` so both parse the same
 * shapes. Returns the top-level key map plus the raw frontmatter lines (for the
 * nested `metadata:` block, which the flat parser deliberately skips).
 */
function splitFrontmatter(text) {
    if (!text.startsWith('---')) return { fm: {}, fmLines: [], error: 'missing frontmatter' };
    const lines = text.split('\n');
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return { fm: {}, fmLines: [], error: 'unterminated frontmatter' };
    const fmLines = lines.slice(1, end);
    const fm = {};
    let i = 0;
    while (i < fmLines.length) {
        const line = fmLines[i];
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
            while (i < fmLines.length && (fmLines[i].startsWith(' ') || fmLines[i] === '')) {
                block.push(fmLines[i].trim());
                i++;
            }
            fm[key] = block.filter((x) => x).join(' ');
            continue;
        }
        fm[key] = unquote(value);
        i++;
    }
    return { fm, fmLines, error: null };
}

/** Parse the 2-space-indented `key: value` lines under a top-level `metadata:`. */
function parseMetadata(fmLines) {
    const meta = {};
    let inMeta = false;
    for (const line of fmLines) {
        const m = line.match(/^(\s*)([A-Za-z0-9_./-]+):\s*(.*)$/);
        if (!m) continue;
        const indent = m[1].length;
        if (indent === 0) {
            inMeta = m[2] === 'metadata';
            continue;
        }
        if (inMeta && indent >= 2) meta[m[2]] = unquote(m[3].trim());
    }
    return meta;
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

const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

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

/** The `## Related` grammar, identical to the linter's `parseRelated`. */
function parseRelated(ctx) {
    if (ctx.relatedIndex === null) return;
    const mask = fenceMask(ctx.lines);
    const end = sectionEnd(ctx.lines, mask, ctx.relatedIndex);
    let current = null;
    for (let i = ctx.relatedIndex + 1; i < end; i++) {
        const line = ctx.lines[i];
        const m = line.match(/\s*-\s*\*\*(Loads|References):\*\*(.*)/);
        if (m) {
            current = m[1].toLowerCase();
            const value = m[2];
            const names = value.trim().replace(/^\(/, '').toLowerCase().startsWith('none')
                ? []
                : extractNames(value);
            addUnique(current === 'loads' ? ctx.loads : ctx.references, names);
            continue;
        }
        if (line.trimStart().startsWith('- ')) {
            current = null;
            continue;
        }
        if (current && line.trim()) {
            addUnique(current === 'loads' ? ctx.loads : ctx.references, extractNames(line));
        }
    }
}

function tableRows(ctx, index) {
    const rows = [];
    if (index === null) return rows;
    const mask = fenceMask(ctx.lines);
    const end = sectionEnd(ctx.lines, mask, index);
    for (let i = index + 1; i < end; i++) {
        if (mask[i]) continue;
        const line = ctx.lines[i].trim();
        if (!line.startsWith('|')) continue;
        const cells = line.replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
        if (cells.length < 3) continue;
        const first = cells[0].replace(/`/g, '').trim();
        if (['file', 'path', ''].includes(first.toLowerCase()) || [...first].every((c) => '-: '.includes(c))) {
            continue;
        }
        rows.push(cells);
    }
    return rows;
}

/** The `## Files` table: `{ path, tier: required|on-demand, trigger }`. */
function parseFiles(ctx) {
    for (const cells of tableRows(ctx, ctx.filesIndex)) {
        ctx.files.push({
            path: cells[0].replace(/`/g, '').trim(),
            tier: cells[1].replace(/`/g, '').trim().toLowerCase(),
            trigger: cells[2].trim(),
        });
    }
}

/** The `## External` table: `{ path, load, trigger }`. */
function parseExternals(ctx) {
    for (const cells of tableRows(ctx, ctx.externalIndex)) {
        ctx.externals.push({
            path: cells[0].replace(/`/g, '').trim(),
            load: cells[1].replace(/`/g, '').trim().toLowerCase(),
            trigger: (cells[2] || '').trim(),
        });
    }
}

/** First sentence of a description, capped at SUMMARY_MAX (ellipsis when cut). */
function summarize(description) {
    if (!description) return '';
    const m = description.match(/^.*?[.!?](?=\s|$)/);
    let s = (m ? m[0] : description).trim();
    if (s.length > SUMMARY_MAX) s = s.slice(0, SUMMARY_MAX - 1).trimEnd() + '…';
    return s;
}

function byKey(key) {
    return (a, b) => (a[key] < b[key] ? -1 : a[key] > b[key] ? 1 : 0);
}

function dedupeBy(rows, key) {
    const seen = new Set();
    const out = [];
    for (const row of rows) {
        if (seen.has(row[key])) continue;
        seen.add(row[key]);
        out.push(row);
    }
    return out;
}

function loadSkill(dir) {
    const id = path.basename(dir);
    const file = path.join(dir, 'SKILL.md');
    const text = fs.existsSync(file) ? readText(file) : '';
    const { fm, fmLines } = splitFrontmatter(text);
    const meta = parseMetadata(fmLines);
    const lines = text.split('\n');
    const mask = fenceMask(lines);
    const ctx = {
        lines,
        relatedIndex: findHeading(lines, mask, 'Related'),
        filesIndex: findHeading(lines, mask, 'Files'),
        externalIndex: findHeading(lines, mask, 'External'),
        loads: [],
        references: [],
        files: [],
        externals: [],
    };
    parseRelated(ctx);
    parseFiles(ctx);
    parseExternals(ctx);
    const description = fm.description || '';
    return {
        id,
        name: fm.name || id,
        lines,
        category: meta.category || null,
        summary: summarize(description),
        description,
        routeWhen: meta['route-when'] || null,
        routeNotWhen: meta['route-not-when'] || null,
        loads: [...new Set(ctx.loads)].sort(),
        references: [...new Set(ctx.references)].sort(),
        files: dedupeBy(ctx.files, 'path').sort(byKey('path')),
        externals: dedupeBy(ctx.externals, 'path').sort(byKey('path')),
        roles: [],
    };
}

function discoverSkills(root) {
    const skillsDir = path.join(root, '.opencode', 'skills');
    const out = [];
    for (const e of fs.readdirSync(skillsDir, { withFileTypes: true })) {
        if (e.isDirectory()) out.push(loadSkill(path.join(skillsDir, e.name)));
    }
    return out.sort(byKey('id'));
}

/** Parse a role brief's optional frontmatter; today's briefs have none. */
function parseRoleFrontmatter(text) {
    const res = { hasFrontmatter: false, role: null, governing: [], contextResolved: false, routeWhen: null };
    if (!text.startsWith('---')) return res;
    const lines = text.split('\n');
    let end = null;
    for (let i = 1; i < lines.length; i++) {
        if (lines[i].trim() === '---') {
            end = i;
            break;
        }
    }
    if (end === null) return res;
    res.hasFrontmatter = true;
    let current = null;
    for (let i = 1; i < end; i++) {
        const dash = lines[i].match(/^\s*-\s+(.+?)\s*$/);
        if (dash && current === 'governing') {
            res.governing.push(unquote(dash[1]));
            continue;
        }
        const m = lines[i].match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
        if (!m) continue;
        const key = m[1];
        const value = m[2].trim();
        current = key;
        if (key === 'role') res.role = unquote(value) || null;
        else if (key === 'context-resolved') res.contextResolved = value === 'true';
        else if (key === 'route-when') res.routeWhen = unquote(value) || null;
        else if (key === 'governing') {
            if (value.startsWith('[') && value.endsWith(']')) {
                res.governing = value.slice(1, -1).split(',').map((s) => unquote(s.trim())).filter(Boolean);
            } else if (value) {
                res.governing = [unquote(value)];
            }
        }
    }
    return res;
}

function discoverRoles(root) {
    const dir = path.join(root, '.opencode', 'skills', 'agent-delegation', 'references', 'roles');
    const out = [];
    if (!fs.existsSync(dir) || !fs.statSync(dir).isDirectory()) return out;
    for (const e of fs.readdirSync(dir, { withFileTypes: true }).sort(byKey('name'))) {
        if (!e.isFile() || !e.name.endsWith('.md')) continue;
        const slug = e.name.slice(0, -3);
        const parsed = parseRoleFrontmatter(readText(path.join(dir, e.name)));
        out.push({
            slug,
            role: parsed.role || slug,
            governing: parsed.governing.slice().sort(),
            contextResolved: parsed.contextResolved,
            hasFrontmatter: parsed.hasFrontmatter,
            routeWhen: parsed.routeWhen,
        });
    }
    return out;
}

/** Return a copy of an object with its keys sorted (byte-stable JSON). */
function sortKeys(obj) {
    const out = {};
    for (const k of Object.keys(obj).sort()) out[k] = obj[k];
    return out;
}

/**
 * A skill is a "part" if its description declares it ("Part of `x`"), or if a
 * parent skill's `## Parts` section covers it. Mirrors lint-skills.mjs so the
 * matrix rows and the linter's allow-list agree.
 */
function isPart(skills, name) {
    const skill = skills.find((s) => s.id === name);
    if (skill && /Part of `[a-z0-9-]+`/.test(skill.description)) return true;
    for (const parent of skills) {
        if (parent.id === name || !name.startsWith(parent.id + '-')) continue;
        const mask = fenceMask(parent.lines);
        if (findHeading(parent.lines, mask, 'Parts') !== null) return true;
    }
    return false;
}

function build(root) {
    const skills = discoverSkills(root);
    const roles = discoverRoles(root);

    for (const role of roles) {
        for (const id of role.governing) {
            const skill = skills.find((s) => s.id === id);
            if (skill && !skill.roles.includes(role.slug)) skill.roles.push(role.slug);
        }
    }
    for (const skill of skills) skill.roles.sort();

    const skillMap = {};
    for (const skill of skills) {
        skillMap[skill.id] = sortKeys({
            id: skill.id,
            name: skill.name,
            category: skill.category,
            summary: skill.summary,
            description: skill.description,
            routeWhen: skill.routeWhen,
            routeNotWhen: skill.routeNotWhen,
            loads: skill.loads,
            references: skill.references,
            files: skill.files.map((f) => sortKeys({ path: f.path, tier: f.tier, trigger: f.trigger })),
            externals: skill.externals.map((x) => sortKeys({ path: x.path, load: x.load, trigger: x.trigger })),
            roles: skill.roles,
        });
    }

    const roleMap = {};
    for (const role of roles) {
        roleMap[role.slug] = sortKeys({
            role: role.role,
            governing: role.governing,
            contextResolved: role.contextResolved,
            hasFrontmatter: role.hasFrontmatter,
            routeWhen: role.routeWhen,
        });
    }

    // One row per skill in the routing matrix: the skill's route-when sentence
    // is the task, its id the governing skill, its Loads the companions.
    const matrixRows = skills
        .filter((s) => !NON_MATRIX_ALLOWLIST.has(s.id) && !isPart(skills, s.id))
        .map((s) => sortKeys({ task: s.routeWhen, governing: [s.id], companions: s.loads.slice() }))
        .sort((a, b) => (a.governing[0] < b.governing[0] ? -1 : a.governing[0] > b.governing[0] ? 1 : 0));

    return sortKeys({
        schema: SCHEMA,
        skills: sortKeys(skillMap),
        roles: sortKeys(roleMap),
        matrixRows,
        count: skills.length,
    });
}

// ------------------------------------------------------------ render blocks

/** `matrix_row.criteria`: keyed by each matrix task (route-when) → skill summary. */
function matrixCriteria(catalog) {
    const criteria = {};
    for (const row of catalog.matrixRows) {
        criteria[row.task] = catalog.skills[row.governing[0]].summary;
    }
    return sortKeys(criteria);
}

/** `role_routing.criteria.role.criteria`: keyed by each role → its route-when. */
function roleCriteria(catalog) {
    const criteria = {};
    for (const [slug, role] of Object.entries(catalog.roles)) {
        criteria[slug] = role.routeWhen;
    }
    return sortKeys(criteria);
}

function renderMatrixBlock(catalog) {
    const lines = [START_MARKER, '| Task | Governing skills |', '|---|---|'];
    for (const row of catalog.matrixRows) {
        let cell = '`' + row.governing[0] + '`';
        if (row.companions.length) {
            cell += ' (+ ' + row.companions.map((c) => '`' + c + '`').join(', ') + ')';
        }
        lines.push(`| ${row.task} | ${cell} |`);
    }
    lines.push(END_MARKER);
    return lines.join('\n');
}

function renderRoleTaskBlock(catalog) {
    const lines = [START_MARKER, '| Task | Role |', '|---|---|'];
    for (const slug of Object.keys(catalog.roles).sort()) {
        const role = catalog.roles[slug];
        lines.push(`| ${role.routeWhen} | ${role.role} |`);
    }
    lines.push(END_MARKER);
    return lines.join('\n');
}

function renderRoleGoverningBlock(catalog) {
    const lines = [START_MARKER, '| Role | Governing skills |', '|---|---|'];
    for (const slug of Object.keys(catalog.roles).sort()) {
        const role = catalog.roles[slug];
        if (!role.governing.length) continue;
        let cell = role.governing.join(', ');
        if (role.contextResolved) cell += " (+ the change's own governing skills)";
        lines.push(`| ${role.role} | ${cell} |`);
    }
    lines.push(END_MARKER);
    return lines.join('\n');
}

/** Replace the hand table whose header matches `headerRegex` with `content`. */
function replaceHandTable(text, headerRegex, content) {
    const lines = text.split('\n');
    const idx = lines.findIndex((l) => headerRegex.test(l));
    if (idx === -1) return null;
    let end = idx;
    while (end + 1 < lines.length && /^\s*\|/.test(lines[end + 1])) end++;
    return [...lines.slice(0, idx), ...content.split('\n'), ...lines.slice(end + 1)].join('\n');
}

/**
 * Apply the generated blocks to a SKILL.md. Once the markers are present they
 * are authoritative — the i-th marker pair takes the i-th block, so a file with
 * two blocks (agent-delegation) maps each pair correctly. On the first run the
 * hand table named by each block's `headerRegex` is replaced.
 */
function applyBlocks(text, blocks) {
    if (!text.includes(START_MARKER)) {
        let out = text;
        for (const block of blocks) {
            const next = replaceHandTable(out, block.headerRegex, block.content);
            if (next === null) {
                throw new Error(`build-catalog: could not locate the hand table for the ${block.label}`);
            }
            out = next;
        }
        return out;
    }
    let out = '';
    let cursor = 0;
    for (const block of blocks) {
        const start = text.indexOf(START_MARKER, cursor);
        if (start === -1) {
            throw new Error(`build-catalog: missing start marker for the ${block.label}`);
        }
        const end = text.indexOf(END_MARKER, start + START_MARKER.length);
        if (end === -1) {
            throw new Error(`build-catalog: missing end marker for the ${block.label}`);
        }
        out += text.slice(cursor, start) + block.content;
        cursor = end + END_MARKER.length;
    }
    out += text.slice(cursor);
    return out;
}

/** The gates.json text with its two generated option sets refreshed. */
function renderGates(text, catalog) {
    const gates = JSON.parse(text);
    gates.gates.matrix_row.criteria = matrixCriteria(catalog);
    gates.gates.role_routing.criteria.role.criteria = roleCriteria(catalog);
    return JSON.stringify(gates, null, 2) + '\n';
}

// --------------------------------------------------------------- tree.json

/**
 * The routing tree's derived half: `branches` (one entry per category present,
 * its skill ids sorted) and `leaves` (one entry per skill, keyed and sorted by
 * id). Sorted and timestamp-free, so two runs are byte-identical.
 */
function deriveTree(catalog) {
    const byCategory = new Map();
    for (const [id, skill] of Object.entries(catalog.skills)) {
        const category = skill.category ?? null;
        if (!byCategory.has(category)) byCategory.set(category, []);
        byCategory.get(category).push(id);
    }
    const branches = [...byCategory.entries()]
        .map(([category, ids]) => ({ category, skills: ids.slice().sort() }))
        .sort((a, b) => (String(a.category) < String(b.category) ? -1 : String(a.category) > String(b.category) ? 1 : 0));
    const leaves = {};
    for (const id of Object.keys(catalog.skills).sort()) {
        leaves[id] = { category: catalog.skills[id].category, routeWhen: catalog.skills[id].routeWhen };
    }
    return { branches, leaves };
}

/**
 * Refresh the derived keys of tree.json, preserving the hand-authored
 * `crossCutting` and `progressiveDisclosure`, in canonical key order.
 */
function renderTree(text, catalog) {
    const tree = JSON.parse(text);
    const { branches, leaves } = deriveTree(catalog);
    return JSON.stringify(
        {
            schema: tree.schema,
            crossCutting: tree.crossCutting,
            progressiveDisclosure: tree.progressiveDisclosure,
            branches,
            leaves,
        },
        null,
        2,
    ) + '\n';
}

function main(argv) {
    const check = argv.includes('--check');
    const root = findRoot(HERE);
    if (!root) {
        console.error('build-catalog: could not locate .opencode/skills');
        return 2;
    }
    const catalog = build(root);
    const skillsDir = path.join(root, '.opencode', 'skills');

    const targets = [
        { path: path.join(skillsDir, 'catalog.json'), text: JSON.stringify(catalog, null, 2) + '\n' },
    ];

    const swPath = path.join(skillsDir, 'software-development', 'SKILL.md');
    targets.push({
        path: swPath,
        text: applyBlocks(readText(swPath), [
            {
                label: 'routing matrix',
                headerRegex: /^\s*\|\s*Task\s*\|\s*Governing skills\s*\|/,
                content: renderMatrixBlock(catalog),
            },
        ]),
    });

    const adPath = path.join(skillsDir, 'agent-delegation', 'SKILL.md');
    targets.push({
        path: adPath,
        text: applyBlocks(readText(adPath), [
            {
                label: 'task→role table',
                headerRegex: /^\s*\|\s*The work\s*\|\s*Role\s*\|/,
                content: renderRoleTaskBlock(catalog),
            },
            {
                label: 'role→governing table',
                headerRegex: /^\s*\|\s*Role\s*\|\s*Governing skills\s*\|/,
                content: renderRoleGoverningBlock(catalog),
            },
        ]),
    });

    const gatesPath = path.join(skillsDir, 'jev-gates', 'assets', 'gates.json');
    targets.push({ path: gatesPath, text: renderGates(readText(gatesPath), catalog) });

    const treePath = path.join(skillsDir, 'tree.json');

    if (check) {
        let stale = 0;
        for (const target of targets) {
            const rel = path.relative(root, target.path);
            const existing = fs.existsSync(target.path) ? readText(target.path) : null;
            if (existing === null) {
                console.error(`build-catalog: ${rel} is missing — run without --check to write it`);
                stale++;
            } else if (existing !== target.text) {
                console.error(`build-catalog: ${rel} is stale — run without --check to regenerate it`);
                stale++;
            }
        }
        // tree.json is partly hand-authored: only branches/leaves are checked,
        // so an edit to crossCutting/progressiveDisclosure does not fail --check.
        const treeRel = path.relative(root, treePath);
        if (!fs.existsSync(treePath)) {
            console.error(`build-catalog: ${treeRel} is missing — run without --check to write it`);
            stale++;
        } else {
            let existingTree = null;
            try {
                existingTree = JSON.parse(readText(treePath));
            } catch {
                existingTree = null;
            }
            if (!existingTree) {
                console.error(`build-catalog: ${treeRel} is not valid JSON`);
                stale++;
            } else {
                const expected = deriveTree(catalog);
                if (
                    JSON.stringify(existingTree.branches) !== JSON.stringify(expected.branches) ||
                    JSON.stringify(existingTree.leaves) !== JSON.stringify(expected.leaves)
                ) {
                    console.error(`build-catalog: ${treeRel} branches/leaves are stale — run without --check to regenerate them`);
                    stale++;
                }
            }
        }
        if (stale) return 1;
        console.log('build-catalog: catalog.json, both SKILL.md blocks, gates.json, and tree.json branches/leaves are up to date');
        return 0;
    }

    if (!fs.existsSync(treePath)) {
        console.error('build-catalog: skills/tree.json is missing — hand-author the skeleton (crossCutting, progressiveDisclosure) first');
        return 2;
    }
    for (const target of targets) {
        fs.writeFileSync(target.path, target.text);
        console.log(`build-catalog: wrote ${path.relative(root, target.path)}`);
    }
    fs.writeFileSync(treePath, renderTree(readText(treePath), catalog));
    console.log(`build-catalog: wrote ${path.relative(root, treePath)}`);
    return 0;
}

process.exit(main(process.argv.slice(2)));
