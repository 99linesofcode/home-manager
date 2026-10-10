---
name: obsidian-plugin
description: Obsidian community-plugin development contract — manifest.json and versions.json upkeep, minAppVersion matching the newest Obsidian API used, the tag-driven release, and the community-plugin conventions. Use when building, extending, or releasing an Obsidian plugin, in any repository.
---

# Skill: obsidian-plugin

The contract for developing an Obsidian community plugin. Load it whenever work
touches an Obsidian plugin, in any repository.

## Version of record

`manifest.json` is the plugin's version of record; it carries `version` and
`minAppVersion`. The release is **tag-driven**: the git tag must equal the
`manifest.json` version **exactly** (`1.0.0`, never `v1.0.0`) — Obsidian installs
assets from the release tagged with the exact manifest version.

## minAppVersion must match the APIs used

`minAppVersion` is the **oldest** Obsidian version the plugin runs on, so it must
be the version that introduced the **newest Obsidian API the code uses**. Adopt a
newer API → bump `minAppVersion` in the same change. The community-plugin scan
fails with `obsidianmd/no-unsupported-api` when the code uses an API newer than
the declared floor.

- Check the installed `obsidian` typings (`node_modules/obsidian/obsidian.d.ts`)
  for the `@since` tag on any API you use.
- Avoid deprecated APIs; migrate when the scan recommends it (e.g.
  `PluginSettingTab.display`, deprecated in 1.13.0 in favour of
  `getSettingDefinitions`).

## versions.json

`versions.json` maps each released plugin version to its `minAppVersion`
(`{ "1.2.0": "1.13.0" }`). Obsidian reads it to know each release's floor. Keep
it populated and maintained by the release workflow, not by hand.

## Release

- Build `main.js` (and `manifest.json`, `styles.css` if present) and attach them
  to the release tagged with the exact manifest version.
- Attest the build provenance so users can verify the asset was produced by the
  repository's workflow.
- The release workflow bumps `manifest.json` and updates `versions.json` in the
  same release commit.

## Conventions

- `isDesktopOnly` reflects whether the plugin uses Node/Electron APIs.
- The plugin id is stable; renaming it breaks installs.
- Keep the vault as the system of record; treat external applications as mirrors.
