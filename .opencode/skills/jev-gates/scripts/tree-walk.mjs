#!/usr/bin/env node
/**
 * tree-walk.mjs — the decision-tree runtime.
 *
 * Resolves one request to a skill set and a worker role by composing the Jev
 * gates in order. It owns no gate logic: every decision is one `jev.mjs` call,
 * and `../../catalog.json` supplies the routing data.
 *
 * The walk: `intake_sufficiency` -> `triage_scale` -> `matrix_row` ->
 * `role_routing`. Intake must be sufficient; triage classes 0 and 1 need no
 * skill; `matrix_row` names the governing skill; `role_routing` names the
 * worker role. Any gate that answers `ask`/`escalate` — or any runner failure —
 * stops the walk: the remaining stages are never guessed.
 *
 * Usage:
 *   node tree-walk.mjs '<json state>'        walk one stage; state is JSON
 *   echo '<json state>' | node tree-walk.mjs -    state from stdin
 *   node tree-walk.mjs --two-stage -         the >100-skill upgrade path
 *
 * State fields: `request` (intake and triage), `task` (matrix and role; falls
 * back to `request`), `brief_role` (role, optional).
 *
 * Output: exactly one JSON object on stdout, and exit 0 —
 *   { sufficient, class, scale, skill, role, actions, model_served }
 * `actions` carries each gate's action; a failed or uncertain gate surfaces
 * there and the downstream stages stay null.
 */

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const JEV = path.join(HERE, 'jev.mjs');
const CATALOG_PATH = path.join(HERE, '..', '..', 'catalog.json');

function usage() {
    process.stderr.write("usage: tree-walk.mjs [--two-stage] '<json state>' | tree-walk.mjs [--two-stage] -\n");
}

function fail(message) {
    process.stderr.write(`tree-walk: ${message}\n`);
    process.exit(2);
}

function loadCatalog() {
    try {
        return JSON.parse(fs.readFileSync(CATALOG_PATH, 'utf8'));
    } catch (err) {
        fail(`cannot read the catalog at ${CATALOG_PATH}: ${err.message}`);
    }
}

/**
 * Run one gate by spawning the runner. The runner owns the request shape, the
 * confidence -> action mapping, and its own fail-safe; here we only parse its
 * one JSON object. A missing gate or any runner failure fails safe to `ask`
 * and surfaces the reason, so the walk never guesses.
 */
function runGate(gate, state) {
    const res = spawnSync(process.execPath, [JEV, gate, '-'], {
        input: JSON.stringify(state),
        encoding: 'utf8',
    });
    if (res.error) {
        return { action: 'ask', decision: null, model_served: null, error: res.error.message };
    }
    const stdout = (res.stdout || '').trim();
    if (stdout) {
        try {
            const parsed = JSON.parse(stdout);
            return {
                action: parsed.action,
                decision: parsed.decision,
                model_served: parsed.model_served ?? null,
                error: null,
            };
        } catch {
            // fall through to the failure below
        }
    }
    const reason = (res.stderr || '').trim() || `jev.mjs '${gate}' returned no JSON (exit ${res.status})`;
    return { action: 'ask', decision: null, model_served: null, error: reason };
}

// --- the catalog's routing data (for the two-stage upgrade path) -------------

function categoriesOf(catalog) {
    return [...new Set(Object.values(catalog.skills).map((skill) => skill.category))].sort();
}

function skillsOf(catalog, category) {
    return Object.entries(catalog.skills)
        .filter(([, skill]) => skill.category === category)
        .map(([id]) => id)
        .sort();
}

/** The route-when text is the routing key: it identifies the skill uniquely. */
function skillForRouteWhen(catalog, routeWhen) {
    for (const [id, skill] of Object.entries(catalog.skills)) {
        if (skill.routeWhen === routeWhen) return id;
    }
    return null;
}

/** A `choice` question over the seven catalog categories, text from the catalog. */
function categoryQuestion(catalog) {
    const criteria = {};
    for (const category of categoriesOf(catalog)) {
        criteria[category] = `${category} — ${skillsOf(catalog, category).join(', ')}`;
    }
    return { type: 'choice', instructions: 'Choose the category this task belongs to.', criteria };
}

/** A `choice` question over the skills within one category, keyed by route-when. */
function skillQuestion(catalog, category) {
    const criteria = {};
    for (const [id, skill] of Object.entries(catalog.skills)) {
        if (skill.category === category) criteria[skill.routeWhen] = skill.summary;
    }
    return { type: 'choice', instructions: 'Choose the one skill that governs this task.', criteria };
}

// --- the walk ---------------------------------------------------------------

function walk(catalog, state, twoStage) {
    const request = state.request;
    const task = state.task !== undefined ? state.task : state.request;
    const briefRole = state.brief_role;

    const result = {
        sufficient: false,
        class: null,
        scale: null,
        skill: null,
        role: null,
        actions: { intake: null, triage: null, matrix: null, role: null },
        model_served: null,
    };
    const note = (gate) => {
        if (gate.model_served) result.model_served = gate.model_served;
    };

    // 1. intake_sufficiency — the request must name a target and state success.
    const intake = runGate('intake_sufficiency', { request });
    result.actions.intake = intake.action;
    note(intake);
    result.sufficient = Boolean(
        intake.decision &&
            intake.decision.names_target === true &&
            intake.decision.states_success_criteria === true,
    );
    // An insufficient intake is an ask, whatever the gate's confidence action:
    // the orchestrator puts the missing target or success criteria to the user.
    if (!result.sufficient) result.actions.intake = 'ask';
    if (!result.sufficient || intake.action !== 'proceed') return result;

    // 2. triage_scale — the class and the scale. Classes 0 and 1 need no skill.
    const triage = runGate('triage_scale', { request });
    result.actions.triage = triage.action;
    note(triage);
    if (triage.decision) {
        result.class = triage.decision.class ?? null;
        result.scale = triage.decision.scale ?? null;
    }
    if (triage.action !== 'proceed') return result;
    if (result.class === '0' || result.class === '1') return result;

    // 3. routing — matrix_row, or the two-stage category -> skill upgrade.
    if (twoStage) {
        // The `category` and `skill` gates are the >100-skill upgrade and are
        // not yet in assets/gates.json; until they are, this fails safe.
        const category = runGate('category', { task, options: categoryQuestion(catalog) });
        result.actions.category = category.action;
        note(category);
        if (category.action !== 'proceed' || typeof category.decision !== 'string') return result;

        const skill = runGate('skill', {
            task,
            category: category.decision,
            options: skillQuestion(catalog, category.decision),
        });
        result.actions.skill = skill.action;
        result.actions.matrix = skill.action;
        note(skill);
        if (skill.action !== 'proceed' || typeof skill.decision !== 'string') return result;
        result.skill = skillForRouteWhen(catalog, skill.decision);
        if (!result.skill) result.actions.matrix = 'ask';
    } else {
        const matrix = runGate('matrix_row', { task });
        result.actions.matrix = matrix.action;
        note(matrix);
        if (matrix.action !== 'proceed' || typeof matrix.decision !== 'string' || matrix.decision === 'none') {
            return result;
        }
        result.skill = skillForRouteWhen(catalog, matrix.decision);
        // A chosen key that matches no skill means the catalog and the gate
        // options have drifted; fail safe rather than route to nothing.
        if (!result.skill) result.actions.matrix = 'ask';
    }
    if (!result.skill) return result;

    // 4. role_routing — the worker role the task warrants.
    const roleState = briefRole === undefined ? { task } : { task, brief_role: briefRole };
    const role = runGate('role_routing', roleState);
    result.actions.role = role.action;
    note(role);
    if (role.action !== 'proceed' || !role.decision) return result;
    result.role = role.decision.role ?? null;

    return result;
}

// --- CLI --------------------------------------------------------------------

const argv = process.argv.slice(2);
const twoStage = argv.includes('--two-stage');
const positional = argv.filter((arg) => arg !== '--two-stage');

if (positional[0] === '--help' || positional[0] === '-h') {
    usage();
    process.exit(0);
}

const catalog = loadCatalog();

let raw;
const source = positional[0];
try {
    if (source && source !== '-') raw = fs.readFileSync(source, 'utf8');
    else if (!process.stdin.isTTY) raw = fs.readFileSync(0, 'utf8');
    else {
        usage();
        process.exit(2);
    }
} catch (err) {
    fail(`cannot read state: ${err.message}`);
}

let state;
try {
    state = JSON.parse(raw);
} catch (err) {
    fail(`state is not valid JSON: ${err.message}`);
}
if (state === null || typeof state !== 'object' || Array.isArray(state)) {
    fail('state must be a JSON object');
}

process.stdout.write(`${JSON.stringify(walk(catalog, state, twoStage))}\n`);
process.exit(0);
