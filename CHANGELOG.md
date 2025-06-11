# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [0.2.0] - 2025-06-11

### Changed 🔧
- Updated `RoxyDialogue` input activation/deactivation logic to use the new priority-based input stack
- Input handlers now registered with `addHandler(self, handler, 100)` and removed with `removeHandler(self)`
- Enabled modal behavior using `Input.makeModalHandler(handler)` if `self.modal` is true

### Breaking Changes ⚠️
- Removed deprecated `saveAndSetHandler` and `restoreHandler` input APIs
- Plugins or forks overriding `activate()` and `deactivate()` must migrate to:
  - `Input.addHandler(owner, handler, priority)`
  - `Input.removeHandler(owner)`
- For modal dialogues, wrap handlers with `Input.makeModalHandler(handler)`
- See [BREAKING_CHANGES.md](./BREAKING_CHANGES.md) for full migration steps

---

## [0.1.1] - 2025-05-29

### Added ✨
- Added top-level `dialogue.lua` as the new entry point for the plugin.
  - Uses `pcall` for safer module loading.
  - Logs load success or failure using `Log.warn` or fallback `warn`.

### Changed 🔧
- Flattened plugin structure: moved contents from `source/roxy/dialogue/` into `core/`.
- Updated initialization flow to align with Roxy Engine conventions.

### Removed ❌
- Removed `init.lua`, previously used as the plugin entry point.

### Breaking Changes ⚠️
- Removed legacy import path `import "roxy/dialogue/init"`.
  - Projects must now use: `import "libraries/roxy-dialogue/dialogue"`.
  - Update all references accordingly.

---

## [0.1.0] - 2025-05-28

### Added ✨
- Added `roxy.dialogue` plugin for animated, multi-page dialogue boxes.
  - Includes `RoxyDialogue`, `RoxyDialogueIndicator`, `Pager`, and `Typewriter`.
  - Supports pagination, typewriter effects, and a default indicator sprite.
  - Ships with default pagination image (`pagination-table-20-20`) in plugin assets.

### Requirements
- This plugin requires the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine) and uses its modules for sprite extensions, asset pools, and input helpers.

### Notes
- Designed to be included in Roxy-based game projects via submodule or as a local plugin.
