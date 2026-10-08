# Implementation sparring — pinning the expensive-to-reverse decisions

Before implementing a slice, spar with the user to settle the decisions that
would be costly to unwind. This is the interactive part of the spec-delta check;
the feature spec is the durable record.

## The judgment call

Not every detail deserves a question. **If a wrong guess would ripple into other
modules or contexts, or be expensive once code exists, ask. If it's local and
easy to correct, state the assumption and move on.**

Worth pinning:

- the architecture or pattern to follow (an existing convention, or a choice for
  this feature);
- public interfaces, data models, or schemas others will depend on;
- non-functional constraints: performance, security, compatibility;
- explicit non-goals;
- how the user wants it verified.

Safe to leave open: internal helper structure, local naming, order of operations
inside a function — anything reversible without touching other files.

## How

1. **One question at a time, and wait.** Don't front-load a checklist; each
   answer changes what's worth asking next.
2. **Say why a question matters** when you raise it — the ripple-vs-local
   reasoning — so the user builds the intuition.
3. **Recap what's been pinned down** in a short list, confirm, then implement
   from that recap as the working spec. Update the feature spec so the durable
   record matches.
