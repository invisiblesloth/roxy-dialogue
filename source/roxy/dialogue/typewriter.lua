--
-- Roxy Typewriter
-- Provides a reusable typewriter‑effect for revealing text from a Pager,
-- with support for normal, fast-forward, and instant reveal modes.
--

local floor <const> = math.floor
local min   <const> = math.min
local max   <const> = math.max

local DEFAULT_BASE_SPEED      <const> = 90 -- Default characters-per-second reveal rate.
local DEFAULT_FAST_MULTIPLIER <const> = 20 -- Multiplier for fast-forward reveal rate.

class("Typewriter").extends()

--
-- ! Initialize
-- Initializes a typewriter effect.
-- @param pager table - A Pager instance supplying page text.
-- @param props table - Optional settings:
--   baseSpeed number       - Characters per second
--   fastMultiplier number  - Multiplier for fast speed
--   instant boolean        - If true, pages render immediately (default: false).
--
function Typewriter:init(pager, props)
  self.pager = pager
  props      = props or {}

  -- Typing speeds
  self.baseSpeed      = props.baseSpeed      or DEFAULT_BASE_SPEED
  self.fastMultiplier = props.fastMultiplier or DEFAULT_FAST_MULTIPLIER
  self.fastSpeed      = props.fastSpeed      or (self.baseSpeed * self.fastMultiplier)

  -- Instant mode flag
  self.instant = props.instant or false

  -- Initialize state for the first page
  self:restart()
end

--
-- ! Restart
-- Resets the typewriter state for the current page.
--
function Typewriter:restart()
  self.pageText         = self.pager:getCurrent()
  self.maxChars         = #self.pageText
  self.currentCharacter = 0
  self.currentRate      = self.baseSpeed
  self.timePerChar      = 1 / self.currentRate
  self.timeAccumulator  = 0
  self.typingComplete   = false
end

--
-- ! Fastforward
-- Speeds up reveal to the fastSpeed.
-- Call when the user requests skipping or speeding through text.
-- @returns nil
--
function Typewriter:fastForward()
  self.currentRate = max(self.currentRate, self.fastSpeed)
  self.timePerChar = 1 / self.currentRate
end

--
-- ! Update
-- Advances the typewriter effect based on elapsed time.
-- @param deltaTime number - Time delta in seconds since last update.
-- @returns string|nil - Substring of the current page to render, or nil if unchanged.
-- @returns boolean    - True if the full page text is now revealed.
--
function Typewriter:update(deltaTime)
  local text     = self.pageText
  local maxChars = self.maxChars

  if self.instant then
    self.currentCharacter = maxChars
    self.typingComplete   = true
    return text, true
  end
  if self.typingComplete then
    return text, true
  end

  -- accumulate and advance one char at a time
  self.timeAccumulator = self.timeAccumulator + deltaTime
  local advanced = false
  while self.timeAccumulator >= self.timePerChar do
    self.timeAccumulator = self.timeAccumulator - self.timePerChar
    self.currentCharacter = self.currentCharacter + 1
    advanced = true
    if self.currentCharacter >= maxChars then
      self.currentCharacter = maxChars
      self.typingComplete   = true
      break
    end
  end

  if not advanced then
    return nil, false
  end

  local fragment = text:sub(1, self.currentCharacter)
  return fragment, self.typingComplete
end

--
-- ! Get `typingComplete`
-- Indicates whether the current page is fully revealed.
-- @returns boolean
--
function Typewriter:isComplete()
  return self.typingComplete
end

--
-- ! Get Current Page
-- Retrieves the current text fragment (partial or full).
-- @returns string
--
function Typewriter:getCurrent()
  return self.pageText:sub(1, self.currentCharacter)
end
