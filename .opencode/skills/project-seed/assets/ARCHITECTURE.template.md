# Architecture

<One paragraph: the system in a sentence.>

## Modules and boundaries

| Module | Owns | Depends on |
|---|---|---|
| | | |

```mermaid
flowchart LR
  UI --> Domain
  Domain --> Infra
```

## Flows

### <flow name>

```mermaid
sequenceDiagram
  participant UI
  participant Action
  participant DB
  UI->>Action: <input>
  Action->>DB: <write>
  DB-->>Action: <result>
```

## Conventions

- <naming, layering, where logic lives — the rules a new contributor follows>

## Invariants

- <what must always hold>
