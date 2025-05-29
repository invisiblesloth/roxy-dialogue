-- source/libraries/roxy-dialogue/dialogue.lua
-- Initialize RoxyDialogue plugin

local logWarn = Log and Log.warn or warn
local logDebug = Log and Log.debug or print

local ok, result = pcall(import, "libraries/roxy-dialogue/core/RoxyDialogue")

if not ok then
  logWarn("Failed to load RoxyDialogue plugin: " .. tostring(result))
else --#DEBUG
  logDebug("RoxyDialogue plugin loaded successfully") --#DEBUG
end
