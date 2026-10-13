# Worker report — <task id>

**Status.** [FINISHED] | [BLOCKED] | [NEEDS_INPUT] | [PARTIAL] — exactly one.
**Done.** <what was completed>
**Not done.** <what wasn't, and why>
**Assumptions.** (expected: none — anything here is an escalation)
**Questions / escalations.** <ambiguity, conflict, or a test believed wrong>

## Governing skills — read and honoured

One line per governing skill from the package, each with one line of
conformance evidence (where in the diff it shows):

- `<skill>` — <the rule> — <evidence>
- A governing skill that could not be read is a blocker; say so under Not done.

## Paths read

Every path the package handed you, and the on-demand ones you opened:

- `<absolute path>` — read | not applicable (<why>)

## Load-bearing pointers — confirmed

Every `required` file and `required` External pointer from the package:

- `<absolute path>` — confirmed (<what it told you>)
- A pointer that did not exist is a blocker, not a silent skip.

## Evidence

Paste the raw gate and test output — not claims. Every command must appear
exactly as you ran it, prefixed with `direnv exec .` (or `nix …`); a gate run
through `npx`, `npm`, or a bare `node` is not accepted:

```
<command>
<output>
```
