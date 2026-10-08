# Client discovery — phrasing questions for a non-technical stakeholder

Discovery runs two ways. When the user is their own client (personal projects),
the questions are answered in-conversation — skip the client-delivery framing.
When the answers live with someone else (a client, a colleague, a relative),
this is how to get them.

## Why it matters

A hotspot like "we're not sure if a returning customer needs a new Account or
reuses the old one" means nothing to a client stated that way. Stated as "if
someone orders again a year later using a different email, should that count as
the same customer for loyalty purposes?", they answer in ten seconds. The
translation is the work: an unresolved ambiguity is cheap to close now, with a
question, and expensive later, once code sits on a guess.

## How

1. **Work one hotspot at a time.** Name the internal decision it blocks in plain
   terms, then draft the client-facing version: concrete, scenario-based, free
   of domain-model or implementation vocabulary. The test is whether someone who
   never saw the model could answer it.
2. **Anchor in a specific example** rather than an abstract rule.
3. **Check the phrasing with the user** before sending — they know the client's
   context and vocabulary.
4. **Never quietly answer a hotspot yourself.** If the user wants a default to
   fall back on, label it a proposed default, not a resolved decision.

## Output

Group by theme, each question paired with the internal decision it unblocks:

```
## Customer identity
**Q:** If someone orders again a year later using a different email, should
that count as the same customer for loyalty purposes?
*Unblocks:* whether Customer is matched by email or needs an explicit merge.
```

Answers flow back into the brief, the decision log, and the open-questions
register.
