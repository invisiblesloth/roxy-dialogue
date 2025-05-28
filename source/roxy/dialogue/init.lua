  -- roxy/dialogue/init.lua
  -- One‑line loader so Roxy can simply `roxy.use("dialogue")`.
  
  local Dialogue = import "roxy/dialogue/dialogue"
  
  if rawget(_G, "roxy") and roxy.registerPlugin then
      roxy.registerPlugin("dialogue", Dialogue)
  end
  
  return Dialogue
