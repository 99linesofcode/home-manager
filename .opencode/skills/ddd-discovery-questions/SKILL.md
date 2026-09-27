---
name: ddd-discovery-questions
description: Turn hotspots, open questions, or ambiguities surfaced during domain modeling into a clean, jargon-free list of questions to bring back to a client — grouped by theme, each tied to the internal decision it unblocks. This is stage 2 of a four-stage DDD discovery pipeline (event storming structuring → this stage → slice planning → implementation elicitation). Trigger when the user has a list of hotspots, uncertainties, or "things we weren't sure about" from a domain model or event storming session and wants to prepare them for a client conversation, review meeting, or follow-up email. Also trigger if the user asks how to phrase a technical ambiguity in language a non-technical stakeholder will understand.
---

# Hotspots → Discovery Questions

## Where this sits

Stage 2 of the discovery pipeline: `ddd-event-storming-to-domain-model` → **this skill** → `ddd-slice-planning` → `ddd-implementation-elicitation`. Input here is the hotspot list from stage 1. Output feeds back into stage 1's model once the client answers, and from there into stage 3. Nothing gets saved to a file at this stage — copy the output forward, or continue in the same conversation.

## Why this stage matters

A hotspot like "we're not sure if a returning customer needs a new Account or reuses the old one" means nothing to a client stated that way — but stated as "if someone orders again a year later using a different email, should that count as the same customer for loyalty purposes?" they can answer it in ten seconds. The translation work is the point of this stage: an unresolved ambiguity is cheap to close now, with a question, and expensive to close later, once code has been written on top of a guess.

## How to run it

1. **Get the hotspots.** Pull them from the conversation if `ddd-event-storming-to-domain-model` ran earlier in this thread; otherwise ask the user to paste or describe them.

2. **Work one hotspot at a time.** For each one:
   - First, make sure you and the user agree on what's actually uncertain, and name the decision it blocks in plain terms ("this affects whether Order and Subscription are one aggregate or two — which changes what can be updated independently").
   - Draft a client-facing version: concrete, scenario-based, free of DDD or implementation vocabulary. A good test is whether the question could be answered by someone who has never seen the event storming board. Where it helps, anchor the question in a specific example rather than an abstract rule.
   - Check the phrasing with the user before moving to the next hotspot — they know the client's context and vocabulary better than you do, and a question that reads fine to a developer can still be ambiguous or loaded to a client.
   - As you rephrase, say briefly why the client-facing version works — what jargon it removes, what scenario it anchors to. The user is learning the translation, not just receiving it.

3. **Don't quietly answer a hotspot yourself**, even if the answer seems obvious. The reason it was flagged as a hotspot in stage 1 is that the room didn't converge on it; a plausible-sounding assumption here is exactly the kind of thing that causes rework two stages later. If the user wants to propose a default answer to fall back on if the client is slow to respond, that's fine — but keep it labeled as a proposed default, not a resolved decision.

4. **If the user is their own client** (personal projects), the questions are answered in-conversation rather than sent out — skip the client-delivery framing and work the answers straight back into the model.

## Output format

Group the final questions by theme or bounded context, and for each one note (briefly, for the user's own reference — this part isn't meant for the client) which internal decision the answer unblocks. Something like:

```
## Customer identity
**Q for client:** If someone orders again a year later using a different email, should that count as the same customer for loyalty purposes?
*Unblocks:* whether Customer is matched by email or needs an explicit merge/link mechanism.
```

Close with:
- A short "carry forward" block the user can copy into the next conversation
- A pointer to `ddd-slice-planning` as the next stage, once the client has answered — noting that stage 3 works from a model that's stable enough to commit to, so it's usually worth waiting for these answers first

## Related

- **Loads:** (none — pipeline stages are invoked separately by the user)
- **References:** `ddd-event-storming-to-domain-model` (upstream hotspot source), `ddd-slice-planning` (next stage)
