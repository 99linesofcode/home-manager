---
name: threat-modeling
description: Model a system, feature, or change to enumerate security threats before or during a review. Use when reviewing architecture or design for security, scoping a security review, or as the first step of a red-team/adversarial review. Produces a STRIDE threat model that scopes what to attack.
---

# threat-modeling

The analysis step of a red-team review: understand what you're defending, where the trust boundaries are, and what could go wrong, before you hunt for vulnerabilities. Threat modeling is a design-phase activity — it catches architectural mistakes (a missing trust boundary, an over-trusted service, an authorization gap) that code review alone misses.

## When to use

- Reviewing a system, feature, or change for security (design or architecture review).
- Scoping a security review before hunting vulnerabilities.
- First step of a red-team / adversarial review (with `security-review` and `edge-case-analysis`).

## What to produce

A threat model with these sections:

1. **Scope** — what system/feature/change is in scope, what is out.
2. **Assets** — the data and capabilities worth protecting, with sensitivity.
3. **Trust boundaries** — every line where data crosses from a less-trusted to a more-trusted zone.
4. **Data flows** — entry points (where untrusted input enters) and sinks (where it reaches a dangerous operation), with the flows that cross trust boundaries flagged.
5. **STRIDE threat table** — one row per threat: component, STRIDE category, description, likelihood, mitigation (or "unmitigated").
6. **Prioritized attack surface** — the ranked list of threats that scope the subsequent review.

## Method

- Decompose the system into external entities, processes, data stores, and data flows.
- Mark every trust boundary. Data flows that cross a boundary are the highest-value targets.
- Apply STRIDE to each element, focusing on trust-boundary crossings:
  - **S**poofing (breaks authentication)
  - **T**ampering (breaks integrity)
  - **R**epudiation (breaks non-repudiation)
  - **I**nformation disclosure (breaks confidentiality)
  - **D**enial of service (breaks availability)
  - **E**levation of privilege (breaks authorization)
- For each high-value attacker goal, build an attack tree to find the cheapest unmitigated path.

## Contract

- Every threat is concrete and tied to a specific component or data flow — never a generic "the system could be attacked."
- Every threat gets a mitigation, or is explicitly flagged unmitigated (an open risk).
- Trust-boundary crossings are enumerated, not hand-waved.
- The output ends with a prioritized attack surface that the review will actually use.

## Related

- **Loads:** (none)
- **References:** `security-review`, `edge-case-analysis` (the review steps this scopes)
