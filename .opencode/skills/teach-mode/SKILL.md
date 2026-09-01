---
name: teach-mode
description: The user's teaching contract — how to run a structured lesson when the user wants to learn a subject. Triggers on "teach me X", "teach mode", "I want to learn X", "walk me through X", "give me a lesson on X", "explain X to me" when the intent is learning. Starts by finding the boundary of what the user knows, then teaches only what advances it. Structured lesson flow, wiki-first grounding, explain-back + checkpoint verification, summary note to the vault Inbox.
license: Apache-2.0
compatibility: OpenCode and any agent compatible with the agentskills.io v1 spec
---

# teach-mode

The user's teaching contract. When the user says "teach me X" (or otherwise
enters teach mode), run a **structured lesson** that follows this flow and
verification protocol. This encodes *how the user wants to learn* — not generic
pedagogy. The model already knows how to teach; this skill defines what a
teaching session must look like for this user.

## When to use

- "teach me X", "teach mode", "I want to learn X"
- "walk me through X", "give me a lesson on X", "explain X to me" **when the
  intent is learning** (not a quick answer)
- Any request to be taken through a subject step by step

A quick factual question ("what is X?") is a normal answer, not teach mode.
Teach mode is when the user wants to *learn*, not just be told.

## Session structure (the lesson flow)

One concept at a time. Do not dump the whole subject.

1. **Assess** — start with a couple of questions to find the boundary of what
   the user already knows (a probe, not an exam). Determine where their
   knowledge ends so the lesson starts at that edge.
2. **Scope** — confirm the subject and target depth. If the subject is large,
   propose breaking it into a sequence of lessons (one concept per session)
   rather than cramming.
3. **Concept** — state the concept plainly, in one or two sentences.
4. **Explanation** — elaborate, following the wiki-first grounding rule below.
5. **Concrete example** — a worked, concrete example (not abstract). Tie it to
   the user's world where possible (their projects, their stack, their vault).
6. **Exercise** — one small exercise or practice problem for the user to
   attempt.
7. **Check understanding** — verify before moving on (protocol below).

### Work at the boundary

Teach only the concepts necessary to advance the user's knowledge. If the
assessment shows they already know part of the subject, skip it and start at
the gap. Every concept should move them from what they know to the next thing
they don't — never re-cover ground, never jump ahead.

## Wiki-first grounding

When the subject is covered in the wiki
(`~/Documents/Obsidian/AI/wiki/`), use the concept/source pages as the base
material and cite them (e.g. "this follows from the [[ddd]] concept page").
Read `wiki/index.md` first to locate pages, then drill in. Use general
knowledge only when the wiki lacks coverage — and say so explicitly.

## Verification protocol (before moving on)

Use **all three**, at natural checkpoints (after each concept, or after 2–3
small ones):

- **Explain back** — ask the user to summarize the concept in their own words;
  correct gaps, don't just confirm.
- **Checkpoint questions** — ask 1–2 targeted questions that probe
  *understanding*, not recall.
- **Exercise** — the lesson-flow exercise doubles as a check; grade it and
  explain the result.

Move on only when the user demonstrates understanding — or explicitly says to
move on.

## When the user is stuck

- Re-explain the same concept from a different angle with a **fresh
  analogy/example**.
- If still stuck, simplify to the smallest viable version of the concept, then
  rebuild.
- Never just repeat the same explanation louder.

## Artifacts

- Teaching happens in chat.
- All user-facing output follows the `communication-standards` skill (the
  stop-slop filter) — no AI-typical filler, no binary-contrast crutches, no
  em-dash overuse.
- At the end of the session, write a **summary note** to the vault **Inbox/**
  as a unique, timestamped note: `Inbox/YYYY-MM-DD - <subject>.md`.
- The note is a **capture point, not a final location**. The user has not
  settled on an overarching Obsidian structure yet — do NOT file it into a
  project/area/resource folder. The user will move it themselves, or together
  with the agent, later.
- Keep the note concise: subject, key concepts, examples, open questions.

## Edge cases

- **Large subject** — propose a lesson sequence; never cram a whole subject
  into one session.
- **User already knows part of it** — ask what they know, skip ahead to the
  gap.
- **Quick question vs. teach mode** — a one-off "what is X?" gets a direct
  answer; teach mode is when they want to learn.
- **Wiki lacks coverage** — teach from general knowledge, say so, and offer to
  capture the material as a wiki concept page afterwards.