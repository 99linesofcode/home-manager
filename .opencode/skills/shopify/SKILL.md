---
name: shopify
description: Work with a Shopify store programmatically — acquire the latest Shopify CLI through nix and pnpm, authenticate, and run Admin GraphQL reads, mutations, and bulk operations. Use when updating Shopify products, variants, prices, inventory, or orders; running shopify store execute or bulk; or scripting against the Admin API.
metadata:
  category: tooling
  route-when: "Use when working with a Shopify store programmatically — acquiring or running the Shopify CLI, authenticating to a store, or running Admin GraphQL reads, mutations, or bulk operations against products, variants, prices, inventory, or orders."
  route-not-when: "Use for Shopify store data and Admin API operations only — not theme development, Hydrogen storefronts, or building a distributed app."
---

# shopify

The contract for working with a Shopify store programmatically: acquire the
latest Shopify CLI through nix and pnpm, authenticate once, then run Admin
GraphQL — reads, single mutations, and bulk operations — in house style.

This is a platform skill. It encodes *how* we work with Shopify — the
toolchain, the safety rules, the conventions — not any one job. Updating
prices, loading inventory, or exporting orders are uses of it.

## Related

- **Loads:** (none)
- **References:** (none)

## Files

Before acting, read (or run) every `required` file below.

| File | Load | Read when |
|---|---|---|
| `scripts/shopify` | required | always — it is the wrapper that runs the latest CLI |

## The CLI (nix + pnpm — never a global npm install)

Never install the Shopify CLI with a system `npm`. Run it through
`scripts/shopify`, which:

- gets Node from `nixpkgs` (`nixpkgs#nodejs_22`) — a version independent of
  whatever the system happens to have;
- uses pnpm to install `@shopify/cli@latest` **globally** into a disposable
  `PNPM_HOME` (default `/tmp/shopify-cli`, overridable with `SHOPIFY_CLI_HOME`);
- always installs the **latest** release (idempotent, ~1–2s when cached);
- passes `--allow-build=esbuild` so pnpm 11 does not fail the install over
  esbuild's postinstall script.

Invoke it exactly as `shopify`:

```bash
scripts/shopify version
scripts/shopify store --help
```

A nixpkgs `shopify-cli` may lag the latest release and can miss the `store`
topic entirely — that is why we install via pnpm, never `nix run
nixpkgs#shopify-cli`.

## Authenticate

Two routes; pick by cadence.

- **Interactive (one-off):** `shopify store auth --store <store>.myshopify.com
  --scopes <scopes>`. Opens a browser; the session is stored on the machine.
- **Unattended (recurring / scripted):** create a custom app in the store admin
  (Settings → Apps and sales channels → Develop apps), grant the Admin API
  scopes, install it, and use its Admin API access token in your own client. A
  CLI session expires; a token does not.

Request the **minimum** scopes the operation needs. Product reads →
`read_products`; product writes → `write_products`; inventory reads/writes →
`read_inventory`/`write_inventory`. Never a broad fallback scope.

## Run store operations

`shopify store execute` runs one Admin GraphQL operation; `shopify store bulk
execute` runs one as an asynchronous bulk operation for large volumes.

- Read: `shopify store execute --store <store> --query '<query>'`.
- Mutation: add `--allow-mutations` — the CLI refuses to write store data
  without it.
- Bulk: `shopify store bulk execute --store <store> --allow-mutations
  --query '<mutation>' --variable-file <file.jsonl>`, then track it with
  `shopify store bulk status`. Bulk mutations are disabled by default too.
- Variables: inline with `--variables '<json>'`, or per-line for bulk with a
  JSONL `--variable-file` — one JSON object per line is one mutation
  execution.

## Admin GraphQL conventions

- IDs are global IDs (`gid://shopify/ProductVariant/123`), never bare integers.
  Resolve a product or variant by SKU/handle with a read first.
- **Validate every operation against the Admin API schema before running it.**
  Every mutation's selection set must include `userErrors { field message }`;
  check it is empty before treating the write as done.
- Select no more fields than the job needs.
- Target the current stable Admin API version and state it when the tooling
  allows.

## Safety (non-negotiable for writes)

1. **Back up first.** For a price or inventory change, export the current
   values for every affected ID in the same run — a bulk write is not
   eyeball-reversible.
2. **Dry-run the read.** Resolve and count the exact targets before writing;
   confirm the count matches expectation.
3. **Test on one.** Run the mutation on a single record and check
   `userErrors` and the returned values.
4. **Confirm before mutating.** Show the exact command, the store, the scope,
   and the effect, and get explicit confirmation before any `--allow-mutations`
   run.
5. Never transmit secrets or customer data through the CLI.

## Gotchas

- Prices live on **variants**, not products; a single-option product still has
  one variant.
- `productVariantsBulkUpdate` updates all variants **of one product** per call;
  loop per product, or run it as a bulk operation.
- Bulk mutations are asynchronous: the command returns an operation ID; poll
  `shopify store bulk status` for the result file.
- `productVariantsBulkInput.price` and `compareAtPrice` are per-variant, so a
  product with options needs one entry per variant.
