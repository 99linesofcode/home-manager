---
name: skill-design-principles
description: Decision framework for when to create a skill and what belongs in it. Triggers on: "should I make a skill for this", "what goes in a skill", "how do I decide what to put in a skill", "is this a skill or a role", "designing a skill", "skill boundary", "skill scope". Use before creating any new SKILL.md to determine scope and content. Pairs with skill-authoring.
license: Apache-2.0
compatibility: OpenCode and any agent compatible with the agentskills.io v1 spec
---

# Skill Design Principles

A decision framework for skill scope and content. Use this *before* the skill-authoring workflow to determine whether a skill is needed and what it should contain.

## The core rule: encode what's yours, not what the model already knows

A skill is an onboarding guide, not a training manual. It tells an already-capable agent about *your* standards, *your* context, and *your* definition of done — not how to do a thing the model already knows how to do.

**The new-hire test**: before adding any instruction to a skill, ask — would a competent new hire need to be told this, or would they already know it? If they'd already know it, leave it out.

## When to create a skill

Create a skill when *all three* hold:
1. The task recurs across sessions or agents.
2. The default model output differs from what you want in a consistent, predictable way.
3. The gap is in *your standards or context*, not in the model's general capability.

Do not create a skill to make the model smarter at a task. Create one to make it more *yours*.

## What belongs in a skill

**Include:**
- Output contract — required sections, format, structure, definition of done.
- Epistemic standards — how uncertainty must be communicated, how sources are attributed, what confidence levels mean.
- Domain-specific priors — preferences, tools, libraries, or constraints that are yours and not obvious from the task description.
- Edge cases *you have observed* in real runs that the model handles wrong by default.

**Exclude:**
- Methodology the model already applies well (e.g., "be thorough", "check your work").
- General best practices the model knows (e.g., "use reputable sources").
- Role identity ("you are a meticulous researcher") — this fights the model's self-model and loses in subtle ways.
- Anything you haven't verified is actually needed via a real test run.

## The methodology / contract distinction

For any task with ambiguous execution paths, separate:

- **Methodology** (how to do the work) → leave to the model. Its native intelligence here is broader and more novel than what you'd encode.
- **Contract** (what the output must contain/look like) → encode in the skill.

Example: a research skill should *not* define search strategy or source evaluation. It *should* define that outputs must include a sources section, that confidence must be graded (confirmed / reported / single-source), and that the model must never present unverified claims as established fact.

## Roles vs. skills

Research suggests avoiding dedicated agent roles (personas with fixed personalities). If you find yourself writing "you are a [role]" in a skill, stop — that's a role, not a skill.

Instead, encode the *output properties* the role implies:
- Not: "you are a skeptical fact-checker"
- Yes: "every factual claim must be graded; single-source or blog-only claims must be flagged as unverified"

The latter is testable, composable, and doesn't narrow the model's reasoning approach.

## Skill boundaries: when one skill becomes two

Split a skill when:
- It contains instructions that apply independently (each half would trigger on different tasks).
- The body exceeds ~500 lines and the excess is *not* reference material.
- You notice you're encoding both methodology and contract — separate them.

Example: "research" might split into a `web-research` skill (tool usage, Exa conventions, output format) and an `epistemic-standards` skill (uncertainty communication, source grading) that applies across research *and* other tasks.

## The temperature consideration

Higher orchestrator temperature means more creative, varied execution paths. This is a reason to *narrow* the output contract (be more specific about what done looks like) and *widen* the methodology (give more room to vary how it gets there). Don't over-specify the how just because the output is unpredictable — specify the what more clearly instead.

## Quick decision checklist

Before writing a skill:
- [ ] Have I run this task at least once without a skill and observed a real gap?
- [ ] Is the gap in my standards/context, not in model capability?
- [ ] Can I state the gap as an output property, not a process instruction?
- [ ] Would a competent person need to be told this, or would they already know it?
- [ ] Am I encoding a contract, not a role?

If any answer is no, reconsider whether a skill is the right tool.

## References

- `references/examples.md` — worked examples: research, code review, writing standards
## Related

- **Loads:** `skill-authoring` (the mechanics once the decision is made).
- **References:** (none)
