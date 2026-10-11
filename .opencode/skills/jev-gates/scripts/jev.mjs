#!/usr/bin/env node
/**
 * jev.mjs — a dependency-free runner for the Jev decision gates.
 *
 * A gate is one classification decision the orchestrator must make (triage
 * class, intake sufficiency, routing matrix row, worker role, worker
 * pre-screen, escalation). The gate definitions — model, questions, criteria,
 * thresholds, actions — live in ../assets/gates.json; this script builds the
 * request, calls the OpenRouter Decisions API, maps the answer to a decision
 * and a confidence, and maps the confidence to an action.
 *
 * The action mapping lives here, not in agent prose: the caller acts on
 * `action` (proceed | ask | escalate) and never re-derives it.
 *
 * Usage:
 *   node jev.mjs --list                 # print the gate names, one per line
 *   node jev.mjs <gate> [state.json|-]  # run a gate; state from a file or stdin
 *
 * Environment:
 *   OPENROUTER_API_KEY  required; read from the environment, never logged.
 *
 * Fail-safe: any timeout, non-2xx after retries, network error, JSON parse
 * error, or schema mismatch returns decision:null and an ask/escalate action
 * (per the gate's fail_action) with the reason on stderr, and exits 0 so the
 * caller can still act. It never guesses.
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const GATES_PATH = path.join(HERE, '..', 'assets', 'gates.json');
const ENDPOINT = 'https://openrouter.ai/api/alpha/decisions';
const TIMEOUT_MS = 20000;
const LOG_ROOT = path.join(os.homedir(), 'Documents', 'Obsidian', 'AI', 'logs');

function usage() {
    process.stderr.write('usage: jev.mjs --list | jev.mjs <gate> [state.json | -]\n');
}

function loadGates() {
    try {
        return JSON.parse(fs.readFileSync(GATES_PATH, 'utf8'));
    } catch (err) {
        process.stderr.write(`jev: cannot read gate definitions at ${GATES_PATH}: ${err.message}\n`);
        process.exit(2);
    }
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** Canonical JSON: object keys sorted recursively, so the hash is stable. */
function canonical(value) {
    if (Array.isArray(value)) return `[${value.map(canonical).join(',')}]`;
    if (value && typeof value === 'object') {
        const body = Object.keys(value)
            .sort()
            .map((k) => `${JSON.stringify(k)}:${canonical(value[k])}`)
            .join(',');
        return `{${body}}`;
    }
    return JSON.stringify(value);
}

function stateHash(state) {
    return crypto.createHash('sha256').update(canonical(state)).digest('hex').slice(0, 16);
}

/** Append one line per gate run. Never logs the raw state or the API key. */
function logLine(gateName, modelServed, state, answer, confidence, action) {
    try {
        const dir = path.join(LOG_ROOT, gateName);
        fs.mkdirSync(dir, { recursive: true });
        const record = {
            ts: new Date().toISOString(),
            gate: gateName,
            model_served: modelServed,
            state_hash: stateHash(state),
            answer,
            confidence,
            action,
        };
        fs.appendFileSync(path.join(dir, 'jev.jsonl'), `${JSON.stringify(record)}\n`);
    } catch {
        // Logging is best-effort; it must never fail the run.
    }
}

/**
 * Build the `questions` object for the API from a gate definition.
 *
 * A single-question gate keys its one question by the gate name. A
 * multi-question gate stores its criteria as an object whose values each
 * carry a `type` (noul/choice/score); those keys become the question keys.
 */
function buildQuestions(name, gate) {
    const criteria = gate.criteria;
    const isMulti =
        criteria &&
        !Array.isArray(criteria) &&
        typeof criteria === 'object' &&
        Object.keys(criteria).length > 0 &&
        Object.values(criteria).every(
            (v) => v && typeof v === 'object' && !Array.isArray(v) && typeof v.type === 'string',
        );
    if (isMulti) {
        const out = {};
        for (const [key, q] of Object.entries(criteria)) {
            out[key] = { type: q.type, instructions: q.instructions, criteria: q.criteria };
        }
        return out;
    }
    return { [name]: { type: gate.type, instructions: gate.instructions, criteria } };
}

function confidenceFromProbabilities(probabilities) {
    if (!probabilities || typeof probabilities !== 'object') return 0;
    const values = Object.values(probabilities).filter((v) => typeof v === 'number');
    return values.length ? Math.max(...values) : 0;
}

/** Read one answer by its declared type; any mismatch is a schema failure. */
function readAnswers(response, questions) {
    const answers = response && response.answers;
    if (!answers || typeof answers !== 'object') return { error: 'response has no `answers` object' };

    const decisions = {};
    const confidences = [];
    const probabilityMap = {};
    let probabilityCount = 0;

    for (const [key, question] of Object.entries(questions)) {
        const answer = answers[key];
        if (!answer || typeof answer !== 'object' || answer.type !== question.type) {
            return { error: `answer '${key}' is missing or has the wrong type` };
        }
        if (question.type === 'noul') {
            const p = answer.noul;
            if (typeof p !== 'number' || p < 0 || p > 1) return { error: `answer '${key}' has an invalid noul` };
            decisions[key] = p >= 0.5;
            confidences.push(Math.abs(2 * p - 1));
        } else if (question.type === 'choice') {
            const choice = answer.choice;
            if (typeof choice !== 'string' || !Object.prototype.hasOwnProperty.call(question.criteria, choice)) {
                return { error: `answer '${key}' chose an unknown option` };
            }
            decisions[key] = choice;
            confidences.push(
                typeof answer.confidence === 'number'
                    ? answer.confidence
                    : confidenceFromProbabilities(answer.probabilities),
            );
            if (answer.probabilities) {
                probabilityMap[key] = answer.probabilities;
                probabilityCount++;
            }
        } else if (question.type === 'score') {
            const score = answer.score;
            if (typeof score !== 'number') return { error: `answer '${key}' has an invalid score` };
            const legendValue =
                answer.legend && answer.legend[Math.round(score)] != null ? answer.legend[Math.round(score)] : null;
            decisions[key] = { score, legend: legendValue };
            confidences.push(
                typeof answer.confidence === 'number'
                    ? answer.confidence
                    : confidenceFromProbabilities(answer.probabilities),
            );
            if (answer.probabilities) {
                probabilityMap[key] = answer.probabilities;
                probabilityCount++;
            }
        } else {
            return { error: `question '${key}' has an unsupported type '${question.type}'` };
        }
    }

    const keys = Object.keys(questions);
    const decision = keys.length === 1 ? decisions[keys[0]] : decisions;
    // A multi-question gate is only as confident as its least-confident answer.
    const confidence = confidences.length ? Math.min(...confidences) : 0;
    let probabilities = null;
    if (probabilityCount > 0) probabilities = keys.length === 1 ? probabilityMap[keys[0]] : probabilityMap;
    return { decision, confidence, probabilities };
}

function actionFor(confidence, gate) {
    const act = gate.thresholds && typeof gate.thresholds.act === 'number' ? gate.thresholds.act : 0.75;
    const ask = gate.thresholds && typeof gate.thresholds.ask === 'number' ? gate.thresholds.ask : 0.5;
    if (confidence >= act) return 'proceed';
    if (confidence >= ask) return 'ask';
    return gate.low_action || 'escalate';
}

async function callApi(body, key) {
    let backoff = 500;
    let retries429 = 0;
    let retried5xx = false;
    for (;;) {
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
        let response;
        try {
            response = await fetch(ENDPOINT, {
                method: 'POST',
                headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: controller.signal,
            });
        } catch (err) {
            clearTimeout(timer);
            throw new Error(err && err.name === 'AbortError' ? `timed out after ${TIMEOUT_MS} ms` : `network error: ${err.message}`);
        }
        clearTimeout(timer);
        if (response.status === 429) {
            if (retries429 < 3) {
                await sleep(backoff);
                backoff *= 2;
                retries429++;
                continue;
            }
            throw new Error('HTTP 429 after 3 retries');
        }
        if (response.status >= 500) {
            if (!retried5xx) {
                retried5xx = true;
                await sleep(500);
                continue;
            }
            throw new Error(`HTTP ${response.status} after a retry`);
        }
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        try {
            return await response.json();
        } catch {
            throw new Error('response body is not valid JSON');
        }
    }
}

// --- CLI -------------------------------------------------------------------

const argv = process.argv.slice(2);
if (argv.length === 0 || argv[0] === '--help' || argv[0] === '-h') {
    usage();
    process.exit(argv.length === 0 ? 2 : 0);
}

const definitions = loadGates();

if (argv[0] === '--list') {
    for (const name of Object.keys(definitions.gates)) process.stdout.write(`${name}\n`);
    process.exit(0);
}

const gateName = argv[0];
const gate = definitions.gates[gateName];
if (!gate) {
    process.stderr.write(`jev: unknown gate '${gateName}'\n`);
    process.exit(2);
}

const questions = buildQuestions(gateName, gate);

let parsedState = {};
const source = argv[1];
try {
    const raw = source && source !== '-' ? fs.readFileSync(source, 'utf8') : fs.readFileSync(0, 'utf8');
    if (raw.trim()) parsedState = JSON.parse(raw);
} catch (err) {
    process.stderr.write(`jev: ${gateName}: cannot read state: ${err.message}\n`);
    process.exit(2);
}
if (parsedState === null || typeof parsedState !== 'object' || Array.isArray(parsedState)) {
    process.stderr.write(`jev: ${gateName}: state must be a JSON object\n`);
    process.exit(2);
}
// Smallest sufficient state: send only the declared state_fields that are present.
const state = {};
for (const field of gate.state_fields) {
    if (Object.prototype.hasOwnProperty.call(parsedState, field)) state[field] = parsedState[field];
}

function failSafe(reason, action) {
    const resolved = action || gate.fail_action || 'ask';
    process.stderr.write(`jev: ${gateName}: ${reason}; failing safe -> ${resolved}\n`);
    const output = { gate: gateName, decision: null, confidence: 0, action: resolved, model_served: null, probabilities: null };
    process.stdout.write(`${JSON.stringify(output)}\n`);
    logLine(gateName, null, state, null, 0, resolved);
    process.exit(0);
}

const apiKey = process.env.OPENROUTER_API_KEY;
if (!apiKey) failSafe('OPENROUTER_API_KEY is not set', 'ask');

const body = {
    model: definitions.model,
    state,
    questions,
    provider: { zdr: true },
};

let response;
try {
    response = await callApi(body, apiKey);
} catch (err) {
    failSafe(err.message);
}

const read = readAnswers(response, questions);
if (read.error) failSafe(`schema mismatch: ${read.error}`);

const action = actionFor(read.confidence, gate);
const modelServed = typeof response.model === 'string' ? response.model : null;
logLine(gateName, modelServed, state, read.decision, read.confidence, action);
process.stdout.write(
    `${JSON.stringify({
        gate: gateName,
        decision: read.decision,
        confidence: read.confidence,
        action,
        model_served: modelServed,
        probabilities: read.probabilities,
    })}\n`,
);
process.exit(0);
