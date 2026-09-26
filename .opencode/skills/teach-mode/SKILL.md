---
name: teach-mode
description: The user's teaching contract — how to explain a subject when the user wants to learn. Triggers on "teach me X", "teach mode", "I want to learn X", "walk me through X", "give me a lesson on X", "explain X to me" when the intent is learning. Explains in plain, non-esoteric language, one concept at a time, with concrete examples tied to the user's world. Light assessment and verification — never a grilling. Wiki-first grounding, summary note to the vault Inbox.
license: Apache-2.0
compatibility: OpenCode and any agent compatible with the agentskills.io v1 spec
---

# teach-mode

The user's teaching contract. When the user says "teach me X" (or otherwise
enters teach mode), explain the subject clearly. The default is to **explain
first** — the user often just wants the material laid out plainly, not
interrogated about what they already know. This encodes *how the user wants to
learn*: plain language, one concept at a time, concrete examples, and no
grilling.

## When to use

- "teach me X", "teach mode", "I want to learn X"
- "walk me through X", "give me a lesson on X", "explain X to me" **when the
  intent is learning** (not a quick answer)
- Any request to be taken through a subject step by step

A quick factual question ("what is X?") is a normal answer, not teach mode.
Teach mode is when the user wants to *learn*, not just be told.

## Explain first, in plain language

Default to explaining the subject directly. Do not open with a barrage of
questions. The user can steer; let them.

**Plain language is the rule.** Write the way a competent colleague explains
something to a friend:

- Use everyday words. If a technical term is unavoidable, define it in plain
  words the first time you use it.
- Prefer a concrete analogy over an abstract definition.
- Avoid unexplained jargon, acronyms, and insider shorthand. When you must use
  a term like "nix profile" or "flake", say in one plain sentence what it is
  before leaning on it.
- If the subject has a lot of vocabulary, introduce it one term at a time, not
  all at once.

## Session structure (the lesson flow)

One concept at a time. Do not dump the whole subject.

1. **Concept** — state the concept plainly, in one or two sentences.
2. **Explanation** — elaborate in plain language, following the wiki-first
   grounding rule below.
3. **Concrete example** — a worked, concrete example (not abstract). Tie it to
   the user's world where possible (their projects, their stack, their vault).
4. **Pause** — stop and let the user react. Ask if they want to go deeper, or
   move on. Do not quiz them.

### Assessment (light, optional)

You may ask **one** gentle question to gauge where to start — e.g. "have you
used X before?" — but only if it genuinely helps you pitch the explanation.
If the user seems to want the material explained, just explain it. Never turn
assessment into an interrogation.

### Verification (opt-in, never a grilling)

Do **not** quiz the user by default. No forced "explain back", checkpoint
questions, or exercises unless the user asks for them or it falls out
naturally. The user learns by reading your explanation and asking their own
questions. If you want to check, offer it lightly ("want me to test you on
that, or keep going?") rather than imposing it.

## Work at the boundary

Teach only what advances the user's knowledge. If they already know part of
the subject, don't re-cover it — but don't interrogate them to find out.
Explain, and let them tell you what they already know.

## Wiki-first grounding

When the subject is covered in the wiki
(`~/Documents/Obsidian/AI/wiki/`), use the concept/source pages as the base
material and cite them (e.g. "this follows from the [[ddd]] concept page").
Read `wiki/index.md` first to locate pages, then drill in. Use general
knowledge only when the wiki lacks coverage — and say so explicitly.

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
- **User already knows part of it** — explain, and let them tell you what they
  know; skip ahead to the gap without interrogating.
- **Quick question vs. teach mode** — a one-off "what is X?" gets a direct
  answer; teach mode is when they want to learn.
- **Wiki lacks coverage** — teach from general knowledge, say so, and offer to
  capture the material as a wiki concept page afterwards.

## Related

- **Loads:** (none — loaded on demand)
- **References:** `communication-standards` (how lessons are written),
  `wiki` (wiki-first grounding).
