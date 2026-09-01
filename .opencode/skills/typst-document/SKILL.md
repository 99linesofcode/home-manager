---
name: typst-document
description: Generate a formatted PDF (offerte, contract, or document) from a markdown file using the 99linesofcode typst template in ~/Development/99linesofcode-typst-template. Use when the user wants to convert a markdown document to PDF, create an offerte, or render a document with the typst template.
---

# typst-document

Convert a markdown file to a formatted PDF using pandoc + the typst template
in `~/Development/99linesofcode-typst-template/`.

## When to use

- User wants to generate a PDF from a markdown document (offerte, contract,
  report, etc.)
- User wants to create an offerte (quote) for a client
- User mentions the typst template, pandoc PDF generation, or "maak er een
  PDF van"

## The command

Run from the typst project directory — this is required. Pandoc writes its
intermediate `.typ` file into the current working directory, and the
template's relative assets (`Eindhoven.svg`) resolve from there.

```bash
cd ~/Development/99linesofcode-typst-template && pandoc <input.md> -o <output.pdf> \
  --pdf-engine=typst \
  --template=~/Development/99linesofcode-typst-template/obsidian-typst-template.typ \
  --pdf-engine-opt="--font-path=~/Development/99linesofcode-typst-template"
```

- `<input.md>` — absolute or relative path to the markdown source (can be
  anywhere)
- `<output.pdf>` — **default `~/Documents/<basename>.pdf`**; the user moves
  finished PDFs to their Google Drive by hand

## Example

Input `~/Documents/offerte.md`:

````markdown
---
title: Offerte
subtitle: Kerstboomverhuur
lang: nl
---

# Offerte

```{=typst}
#invoice-table(...)
```
````

Run:

```bash
cd ~/Development/99linesofcode-typst-template && pandoc ~/Documents/offerte.md \
  -o ~/Documents/offerte.pdf \
  --pdf-engine=typst \
  --template=~/Development/99linesofcode-typst-template/obsidian-typst-template.typ \
  --pdf-engine-opt="--font-path=~/Development/99linesofcode-typst-template"
```

Result: `~/Documents/offerte.pdf` (user moves it to Google Drive).

## Document requirements

- YAML frontmatter with `title`, `subtitle`, `lang: nl` (used by the
  template's cover and footer)
- Raw typst blocks (` ```{=typst} `) for tables, pagebreaks, custom
  layout — see the offerte in `Archief/Offertes/` for an example
  (`#invoice-table`, `#pagebreak()`, `#euro()`)
- Images referenced in the markdown must live **next to the .md file** (typst
  resolves relative paths from the generated file in cwd)

## Gotchas

- cwd MUST be `~/Development/99linesofcode-typst-template` — the intermediate `.typ` file lands
  there and the template's relative `Eindhoven.svg` resolves from there
- Fonts (Do Hyeon, Montserrat) must be in `~/Development/99linesofcode-typst-template` or passed via
  `--font-path`
- The template's cover uses `Eindhoven.svg` (relative to cwd)
- Output defaults to `~/Documents/`
- The template imports `@preview/oxifmt:1.0.0` (network fetch on first
  compile; cached afterwards)
