# Skill Design Examples

Worked examples applying the skill design principles.

## Table of contents
- [Research / web browsing](#research--web-browsing)
- [Code review](#code-review)
- [Writing standards](#writing-standards)
- [Counter-example: the role trap](#counter-example-the-role-trap)

---

## Research / web browsing

**The gap observed**: model presents blog-sourced claims with same confidence as peer-reviewed or primary sources. References are inconsistent or absent.

**Wrong approach** (encoding methodology):
> Search at least 5 sources. Cross-reference claims. Prioritize .gov and .edu domains. Use Exa for web browsing. Always check publication dates.

**Right approach** (encoding contract + epistemic standards):
```
## Output contract
Every research output must include:
- A sources section listing all consulted sources with URLs.
- A confidence grade on each major claim: [confirmed] = multiple independent primary sources; [reported] = credible single source or secondary reporting; [unverified] = blog/forum/single reference only.

## Epistemic rules
- Never present a claim without a confidence grade.
- [unverified] claims must include a note suggesting how to verify.
- Do not synthesize [unverified] claims into conclusions presented as established.
```

The model's search strategy, source triangulation, and lateral thinking remain fully open.

---

## Code review

**The gap observed**: model gives generic best-practice feedback, misses repo-specific conventions.

**Wrong approach**:
> Review code carefully. Check for bugs, security issues, and performance problems. Make sure it follows best practices.

**Right approach**:
```
## Contract
Code review output must cover: correctness, test coverage against our TDD standard, and adherence to the conventions in `references/coding-standards.md`. Skip style comments (the linter handles those).

## Our specific priors
- We use Drizzle for DB — flag any raw SQL that bypasses the ORM.
- Test files live in `__tests__/` adjacent to the module — flag any placed elsewhere.
- PRs touching auth/* require a security note even if no issues found.
```

---

## Writing standards

**The gap observed**: outputs include AI-typical phrases ("It's worth noting that...", em dashes as drama, binary contrasts).

> This example is generalized into the `communication-standards` skill, which
> applies to all user-facing output — not just written documents.

**Wrong approach**:
> Write clearly and concisely. Avoid jargon. Use active voice.

**Right approach**:
```
## Output contract
All written output must pass the stop-slop filter before delivery:
- No throat-clearing openers ("It's worth noting", "Certainly", "Great question").
- No em dashes used for dramatic effect.
- No binary contrasts ("Not X. But Y.").
- Active voice default; passive only when the actor is genuinely unknown or irrelevant.

Score each draft mentally on a 1–10 slop scale. Revise anything below 7 before returning.
```

---

## Counter-example: the role trap

**Tempting but wrong**:
```
You are a meticulous, skeptical research analyst with high epistemic standards.
You never accept claims at face value and always seek primary sources.
```

**Why it fails**: this is a role, not a contract. It's untestable, fights the model's existing self-model, and gives no concrete definition of done. The model may perform the persona superficially while still returning ungraded claims.

**What to do instead**: extract the implied output properties and encode those. See the research example above.