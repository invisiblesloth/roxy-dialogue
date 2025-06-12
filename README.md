# Roxy Dialogue Plugin for Roxy Engine

Roxy Dialogue is a plugin for [Roxy Engine](https://github.com/invisiblesloth/roxy-engine) that provides animated, multi-page dialogue boxes with built-in pagination, input control, and typewriter-style effects – ideal for narrative Playdate games.

---

## Features

- Create dialogue boxes with wrapped text and crank or button advancement.
- Shows indicator when text is ready to advance.
- Optional typewriter-style text animation.
- Handles word-wrapping and page breaks.
- Includes a default pagination image for immediate use.

---

## Installation

Add the plugin to your game project using Git submodules:

```bash
git submodule add https://github.com/invisiblesloth/roxy-dialogue source/libraries/roxy-dialogue
````

Build your project:

```bash
pdc source GameName.pdx
```

In your game code, import the plugin and use it:

```lua
import "libraries/roxy-dialogue/dialogue"

-- Usage
local dialogue = RoxyDialogue("It’s dangerous to go alone! Take this.")
dialogue:activate()
```

---

## Requirements

This plugin is designed to be used **with the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine)**.  
It relies on Roxy’s:

- Asset pool system (`roxy.Assets`)
- Sprite subclassing (`RoxySprite`)
- Input utilities and update loop
- Scene integration (`roxy.Scene`)
- Configuration access (`roxy.Configuration`)

It will not work in non-Roxy game projects without modification.

---

## Customization Options

Customize appearance and behavior using `props` when creating a new dialogue:

```lua
local props = {
  x = 50,
  y = 180,
  width = 240,
  height = 70,
  font = yourFont,
  alignment = Text.ALIGN_LEFT,     -- Text alignment
  color = Theme.colors.text,
  background = Theme.colors.panel,
  cornerRadius = 6,                -- Dialogue box roundness
  hasBackground = true,            -- Whether to show a background box
  numberOfLines = 3,               -- Max lines per page
  leading = 2,                     -- Line spacing
  paddingHorizontal = 10,
  paddingVertical = 10,
  zIndex = 1000,                   -- Sprite layer priority
  typingSpeed = 90,                -- Characters per second
  fastMultiplier = 20,             -- Speed boost when fast-advancing
  fastTypingSpeed = 240,           -- Override fast speed if needed
  instant = false,                 -- Show full text immediately
  indicatorX = nil,                -- Override indicator X position
  indicatorY = nil,                -- Override indicator Y position
  inputHandler = nil,              -- Custom input handler (optional)
  modal = true,                    -- If true, wraps handler in makeModalHandler()
  onDismiss = function() end,      -- Callback when dialogue ends
  isActive = true                  -- Auto-starts typewriter on init
}
```

You can also call `dialogue:startTypewriter()` manually if `isActive` is `false`.

---

## License

MIT License.

Roxy Dialogue depends on the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine), also MIT-licensed.

[👉 Details](./LICENSE)

---

**Note:** Roxy and the plugins are currently pre-release software.

Thanks for building with Roxy!
