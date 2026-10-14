# The refactoring catalogue

Every refactoring below is from Martin Fowler's catalogue
(<https://refactoring.com/catalog/>), 2nd edition, with the Ruby Edition's names
where they differ. Each line says **what it is for**; the mechanics for any one
are on its page.

An operation is a **named, behaviour-preserving step**. Apply them in small
steps, each landing green; never do several under one name.

## Composing methods

- **Extract Function** *(Extract Method)* — a fragment wants a name that says
  what it does.
- **Inline Function** *(Inline Method)* — the body is as clear as the name.
- **Extract Variable** *(Introduce Explaining Variable)* — an expression needs a
  name to be read.
- **Inline Variable** *(Inline Temp)* — the name adds nothing the expression
  does not say.
- **Change Function Declaration** *(Change Signature, Rename Function)* — a
  name, parameter list or return wants to change.
- **Encapsulate Variable** *(Encapsulate Field)* — direct access to a variable
  should go through a function.
- **Rename Variable** — the name misleads or says nothing.
- **Introduce Parameter Object** — a group of parameters always travels together.
- **Combine Functions into Class** — several functions work on the same data;
  they are a class waiting to be born.
- **Combine Functions into Transform** — the same derivations run over a record
  in several places.
- **Split Phase** — one function does two things in sequence (parse then
  evaluate, read then write) and the split wants a name.

## Encapsulation

- **Encapsulate Record** *(Replace Record with Data Class)* — a bare structure
  wants behaviour beside its fields.
- **Encapsulate Collection** — a collection is handed out whole; return a
  read-only view and add mutators.
- **Replace Primitive with Object** — a primitive carries a rule or needs
  behaviour.
- **Replace Temp with Query** — a temporary holds a value that could be asked for.
- **Extract Class** — one class has two jobs; split the second out.
- **Inline Class** — a class no longer earns its keep.
- **Hide Delegate** — a client reaches through to a delegate; give the
  intermediary its own method.
- **Remove Middle Man** — the intermediary only forwards; let clients talk to
  the object.
- **Substitute Algorithm** — the same result is reached more clearly another way.

## Moving features

- **Move Function** *(Move Method)* — a function uses another class's data more
  than its own.
- **Move Field** — a field belongs with the class that reads it.
- **Move Statements into Function** — the same statements always accompany a
  call.
- **Move Statements to Callers** — behaviour differs per caller; push the
  difference out.
- **Replace Inline Code with Function Call** — a library call says the same
  thing more directly.
- **Slide Statements** — related statements want to sit together.
- **Split Loop** — one loop does two jobs.
- **Replace Loop with Pipeline** — a loop is a filter/map/reduce in disguise.
- **Remove Dead Code** — nothing reaches it.

## Organizing data

- **Split Variable** *(Remove Assignments to Parameters, Split Temp)* — one
  variable is reused for two purposes.
- **Rename Field** — the field name misleads.
- **Replace Derived Variable with Query** — a stored value can be computed.
- **Change Reference to Value** — an object is shared but treated as a value.
- **Change Value to Reference** — many equal copies should be one shared object.

## Simplifying conditional logic

- **Decompose Conditional** — the condition and its branches need names.
- **Consolidate Conditional Expression** — several conditions lead to the same
  result.
- **Replace Nested Conditional with Guard Clauses** — the happy path is buried
  in nesting.
- **Replace Conditional with Polymorphism** — the same switch appears in
  several places.
- **Introduce Special Case** *(Introduce Null Object)* — a repeated check for a
  special case wants an object that answers for it.
- **Introduce Assertion** — a piece of state must hold for the code to be
  correct.

## Refactoring APIs

- **Separate Query from Modifier** — one call both answers and changes; split it.
- **Parameterize Function** *(Parameterize Method)* — several functions differ
  only by a value.
- **Remove Flag Argument** *(Replace Parameter with Explicit Methods)* — a
  boolean parameter selects behaviour.
- **Preserve Whole Object** — several values are pulled from one object to pass
  along.
- **Replace Parameter with Query** *(Replace Parameter with Method)* — the
  caller can ask for a value it is passing in.
- **Replace Query with Parameter** — a function reaches for something it should
  be told.
- **Remove Setting Method** — a field should be set once, at construction.
- **Replace Constructor with Factory Function** *(Factory Method)* —
  construction needs a name, or a decision.
- **Replace Function with Command** *(Method Object)* — a function needs more
  than a name: state, sub-steps, or a lifecycle.
- **Replace Command with Function** — a command object is a function in costume.
- **Replace Error Code with Exception** — the caller must check a code instead
  of catching a failure.
- **Replace Exception with Precheck** — the exception is thrown for a case the
  caller could have tested.
- **Return Modified Value** — a function updates a value it was handed, hiding
  the change.

## Dealing with inheritance

- **Pull Up Method** — several subclasses carry the same method.
- **Pull Up Field** — several subclasses carry the same field.
- **Pull Up Constructor Body** — subclass constructors share a body.
- **Push Down Method** — a superclass method is used by only one subclass.
- **Push Down Field** — a superclass field is used by only one subclass.
- **Replace Type Code with Subclasses** *(Extract Subclass)* — a type code
  drives behaviour.
- **Remove Subclass** *(Replace Subclass with Fields)* — a subclass does too
  little to exist.
- **Extract Superclass** — two classes share a real common part.
- **Collapse Hierarchy** — a superclass and subclass are no longer distinct.
- **Replace Subclass with Delegate** — inheritance was chosen where delegation
  fits.
- **Replace Superclass with Delegate** *(Replace Inheritance with Delegation)* —
  a subclass uses only part of its superclass.

## Choosing one

Ask what the code is *missing*, not what looks wrong:

- It needs a **name** → Extract Function, Extract Variable, Rename.
- A name **lies** → Change Function Declaration, Rename Variable/Field.
- Things **belong together** → Combine Functions into Class, Slide Statements,
  Move Function.
- Things **belong apart** → Extract Class, Split Phase, Split Loop, Split
  Variable.
- A thing is **used by several places** → Pull Up Method/Field, Extract
  Superclass, Combine Functions into Class.
- A thing is **reached for** → Hide Delegate, Remove Middle Man, Preserve Whole
  Object.
- A **condition** is hard to read → Decompose Conditional, Guard Clauses,
  Consolidate Conditional.
- A **call** does too much → Separate Query from Modifier, Remove Flag Argument.
- Nothing reaches it → Remove Dead Code, Inline.
