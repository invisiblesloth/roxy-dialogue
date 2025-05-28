# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

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
