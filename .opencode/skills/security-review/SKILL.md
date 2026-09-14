---
name: security-review
description: Adversarial security review of source code — hunt for vulnerabilities (access control, injection, crypto, auth, supply chain), validate exploitability, and report evidence-grounded findings. Use when reviewing a diff or codebase for security issues, or as the core red-team step of a code review.
---

# security-review

The adversarial "red team" pass over source code: treat the code as a hostile target and find a path to break it. This is the core of red-team testing — not linting, but actively attacking.

## When to use

- Reviewing a diff or codebase for security vulnerabilities.
- The core red-team step of a code review (with `threat-modeling` to scope and `edge-case-analysis` for robustness).
- Preparing a change for merge and checking it holds up to attack.

## Vulnerability class checklist

Walk the code against these classes (OWASP Top 10:2025-aligned). For each, trace data flow from entry point to sink and check the control:

1. **Broken access control** — IDOR/BOLA (object IDs you can swap), missing function-level checks, privilege escalation, mass assignment, SSRF (uncontrolled outbound requests).
2. **Injection** — SQL/NoSQL, OS command, XSS (reflected/stored/DOM), template (SSTI), LDAP, expression-language, prompt injection.
3. **Cryptographic failures** — weak algorithms, hardcoded keys, broken randomness, secrets in code.
4. **Authentication failures** — weak credential handling, session issues, JWT `alg=none`/`kid` manipulation, missing rate limiting.
5. **Security misconfiguration** — permissive defaults, exposed debug/admin, missing headers, CORS.
6. **Software supply chain** — known-vulnerable dependencies, mutable version tags, phantom deps.
7. **Software/data integrity failures** — unsafe deserialization, missing integrity checks.
8. **Security logging & alerting failures** — missing/insufficient audit logging of sensitive actions.
9. **Mishandling of exceptional conditions** — failing open, swallowing errors, unstable states.

## Method

- **Map** entry points (routes, handlers, IPC, public functions) and the sources of user input.
- **Trace** data flow from each entry point to dangerous sinks (query builders, shell exec, HTML render, file paths, deserializers).
- **Validate** access control: is the check present, and is it against the right identity? Look for missing checks and checks against the wrong thing.
- **Interrogate** adversarially — ask pointed, challenging questions ("what if this ID is another user's?", "what if this input contains a null byte?"). Adversarial framing finds issues; descriptive framing produces rewrites.
- **Verify** — treat every finding as a hypothesis until you can trace a concrete exploit path (file:line). Reproduce high-severity findings.
- **Report** findings with severity, location, what's wrong, the fix, and the evidence.

## Contract

- Every finding is **evidence-grounded**: a file:line reference and a concrete exploit path. A claim without a citation is discarded.
- Every finding is a **hypothesis until verified**. Distinguish "confirmed exploitable" from "theoretical / needs confirmation."
- Findings are reported as **blocking** (must fix before merge) or **non-blocking** (suggestions).
- Adversarial framing only — never rewrite the code as a substitute for finding the issue.
- High-severity findings are cross-checked (a second pass / different lens) before being reported as confirmed.

## Related

- **Loads:** (none)
- **References:** `threat-modeling` (scope), `edge-case-analysis` (robustness), `code-review` (the review it feeds)
