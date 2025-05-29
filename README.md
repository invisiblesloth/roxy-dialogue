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

Build with the additional path:

```bash
pdc -I source/libraries/roxy-dialogue/source source MyGame.pdx
```

In your game code, import the plugin and use it:

```lua
import "libraries/roxy-dialogue/dialogue"

-- Usage
local dialogue = RoxyDialogue("It’s dangerous to go alone! Take this.")
```

---

## Requirements

This plugin is designed to be used **with the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine)**.  
It relies on Roxy’s:

- Asset pool system (`roxy.Assets`)
- Sprite subclassing (`RoxySprite`)
- Input utilities and update loop
- Scene integration (`roxy.Scene`)

It will not work in non-Roxy game projects without modification.

---

## License

MIT License.

Roxy Dialogue depends on the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine), also MIT-licensed.

[👉 Details](./LICENSE)

---

**Note:** Roxy and the plugins are currently pre-release software.

Thanks for building with Roxy!
