# Breaking Changes

This document catalogs all **breaking changes** introduced across the Roxy Dialogue’s releases. Each section below corresponds to a specific version that included incompatible updates requiring developers to adjust their code. For migration details on each change, see the corresponding **code references** and recommended actions.

---

## [0.2.0] - 2025-06-11

### Input Handler API Replaced

**What Changed:**
- Removed deprecated input stack functions `saveAndSetHandler` and `restoreHandler`.
- Updated `RoxyDialogue:activate()` and `:deactivate()` to use `roxy.Input.addHandler(owner, handler, priority)` and `roxy.Input.removeHandler(owner)`.
- Optional modal behavior is now handled explicitly using `roxy.Input.makeModalHandler(handler)`.

**Required Updates:**
If you have custom forks or override `RoxyDialogue`'s input logic:

- **Replace:**
  ```lua
  saveAndSetHandler(handler, mask)
  ...
  restoreHandler()
  ```

- **With:**

  ```lua
  addHandler(self, handler, 100)
  ...
  removeHandler(self)
  ```

- If `self.modal == true`, wrap your handler like this:

  ```lua
  handler = Input.makeModalHandler(handler)
  ```

**Reason:**
This change aligns the plugin with the latest `roxy-engine` core input model, ensuring better control, stack safety, and modular input handling.

---

## [0.1.1] - 2025-05-29

### Plugin Initialization Path Changed

**What Changed:**
- Removed the previous entry point `init.lua`.
- Added a new top-level entry point `dialogue.lua` in `libraries/roxy-dialogue/`.
- Updated internal loading to use `pcall` for safer initialization with fallback logging via `Log.warn` or `warn`.

**Required Updates:**
- Update your plugin import path:

  - **Before:**
    ```lua
    import "roxy/dialogue/init"
    ```

  - **After:**
    ```lua
    import "libraries/roxy-dialogue/dialogue"
    ```

- If you use hardcoded paths in your build process, asset bundling, or plugin loading logic, update those paths to reflect the new structure.

**Reason:**
This structural change simplifies the plugin's layout, improves robustness through error handling, and aligns with Roxy Engine's architectural and naming conventions.

---

## **Additional Notes**

- If you’re **upgrading multiple versions**, review **each** relevant section above to ensure your project is updated correctly at every step.
- For more details on specific changes (including the rationale or performance impact), see the [CHANGELOG.md](./CHANGELOG.md) file or individual commit messages.
