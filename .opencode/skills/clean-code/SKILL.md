---
name: clean-code
description: The umbrella contract for clean code, distilled from Clean Code — intention-revealing names, small functions that do one thing, no duplication, honest error handling, and small cohesive classes. Use when writing, reviewing, or refactoring code, when a unit feels too big, too clever, or too deeply nested, or when judging whether code is clean.
metadata:
  category: review
  route-when: "Use when writing, reviewing, or refactoring code, when judging whether a unit is too big, too clever, or too deeply nested, or when asking whether code is clean."
  route-not-when: "Use `self-documenting-code` for the comment, naming-rhythm, whitespace and file-length contract; `software-architecture` for where logic lives."
---

# clean-code

Clean code is code a reader can change without fear: it does what it says, says
what it does, and has one obvious place to change. This skill is the umbrella —
the rules that make that true, in any language.

It is not a style guide, and it does not restate its neighbours: comments and
naming rhythm, the duplication policy, and where logic lives each have their
own home — `## Related` names them. What is left — the shape of a **name**, a
**function**, an **error**, an **object**, a **class**, and the order in which
you reach for those — is here.

## Related

- **Loads:** `self-documenting-code`.
- **References:** `refactoring`, `software-architecture`, `software-testing`,
  `feature-spec`.

## The bar

A unit is clean when a cold reader can say what it does in one sentence, and
the next change has one obvious place to go. Both are answered by the reader,
not the author.

## Names

A name answers *why it exists, what it does, and how it is used*. If it needs a
comment, the name is wrong.

- **Intention-revealing.** `elapsed_time_in_days`, not `d`.
- **Nouns name classes; verbs name methods.** `Post`, `post.publish`.
- **One word per concept.** Pick `fetch` or `retrieve` or `get` — never all
  three for the same act.
- **No puns.** The same word must not mean two things in one codebase.
- **Meaningful distinctions, not noise words.** `Post` and `PostDraft` differ;
  `PostData` and `PostInfo` and `PostObject` do not.
- **Pronounceable and searchable.** You will say it out loud and grep it.
- **No encodings.** No type prefixes, no `m_`, no Hungarian — the language and
  the type checker already know.
- **No mental mapping.** A reader must not translate `r` into `row`.

```ruby
# No — says nothing, needs a comment to live
def calc(a, b) = a * b

# Yes — the call site reads as a sentence
def total_for(quantity, unit_price) = quantity * unit_price
```

## Functions

**Small. Then smaller.** Size is not the metric; *one thing* is.

- **Do one thing** — one level of abstraction below the name. If you can extract
  a function whose name is not a restatement of its body, the original did more
  than one thing.
- **One level of abstraction per function.** Don't mix `parse` with
  `save_to_disk` in one body.
- **Few arguments.** Zero to two is comfortable; three needs justifying; more
  needs an object. A **flag argument** means the function does two things —
  split it.
- **No side effects.** A function must not promise one thing and quietly do
  another (set a global, write a field, cache a value).
- **Command-query separation.** Either do something or answer something — never
  both.
- **Prefer exceptions to error codes.** An error code forces a check on every
  call and hides the failure path.
- **Don't repeat yourself** — the policy is `refactoring`'s.

```ruby
# No — three levels in one body, and a flag that splits the behaviour
def publish(post, notify)
  return unless post.draft?
  post.update!(status: :published)
  Notify.call(post.author, post) if notify
  Audit.log(post)
end

# Yes — one level each, the names carry the steps
def publish(post)
  return unless post.draft?
  mark_published(post)
  announce(post)
  record_in_audit(post)
end
```

## Error handling

- **Exceptions, not return codes.** The failure travels to whoever can handle
  it, instead of being checked at every step.
- **Write the failing path first.** It defines the scope you must keep safe.
- **Context in the exception** — the operation, the input, the reason. An error
  that says only "invalid" costs the reader the whole investigation.
- **Name exceptions for the caller's catch.** One class per *how it is handled*,
  not per *where it came from*.
- **Never return `null`; never pass `null`.** A null return forces every caller
  to guard; a null argument is a trap. Answer with a real object (a Null Object)
  or raise.

```ruby
# No — nil travels silently and every caller must remember
def author_of(post) = post.author

# Yes — the caller gets something it can use
def author_of(post) = post.author || Guest.new
```

## Objects and data

Objects hide their data behind behaviour; data structures expose data and carry
none. **Don't mix the two** — a half-object/half-structure invites both
accesses and loses both guarantees.

- **Law of Demeter.** Talk to your friends, not strangers. `post.author.city` is
  a train wreck: it reaches through two objects and couples you to both.
- **Ask, don't reach.** `post.author_city` keeps the knowledge where the data
  lives.

```ruby
# No
post.author.address.city

# Yes
post.author_city
```

## Classes

Small — measured in **responsibilities**, not lines.

- **One reason to change** (SRP). The name should say the one thing it is for.
- **High cohesion.** Fields and methods that belong together stay together; when
  a subset no longer touches the rest, that subset wants to be its own class.
- **Depend on abstractions, not concretions** — how that is expressed here
  (actions, ports, DTOs, services) is `software-architecture`'s contract.

## Emergence — the four rules of simple design

In this order, and each in service of the one before:

1. **Runs all the tests.** Untested code cannot be called clean.
2. **Contains no duplication.** The policy is `refactoring`'s — abstract after
   the second or third repetition, consolidate only byte-identical bodies.
3. **Expresses intent.** Names and structure say what the code is for.
4. **Minimises classes and methods.** Fewest elements that do the job — the
   lean guardrail.

## Smells

- Dead code; commented-out code; duplicate code.
- A function that needs a comment, a long body, or deep nesting.
- A flag argument; an output argument; more than three arguments.
- A name that misleads, or two names for one concept.
- Returning or passing `null`.
- Feature envy — a method more interested in another object's data than its own.
- Temporal coupling — two things that must happen in an order nothing states.
- A class that can only be understood by reading all of it.

## Ruby

Examples are Ruby, per the house convention: method names in `snake_case`, a
predicate reads as a question (`draft?`), and a one-line body uses the endless
method form when it stays readable.
