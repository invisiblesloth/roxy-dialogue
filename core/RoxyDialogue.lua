-- RoxyDialogue

local logError <const> = Log.error --#DEBUG
local logWarn  <const> = Log.warn  --#DEBUG
local logDebug <const> = Log.debug --#DEBUG

-- ---------------------------------- --
-- ! Module & SDK Aliases             --
-- ---------------------------------- --

local pd       <const> = playdate
local Graphics <const> = pd.graphics
local Assets   <const> = roxy.Assets
local Cache    <const> = roxy.Cache
local Input    <const> = roxy.Input
local Text     <const> = roxy.Text

-- ---------------------------------- --
-- ! Performance-Oriented Aliases     --
-- ---------------------------------- --

-- Table / math
local concat   <const> = table.concat
local floor    <const> = math.floor
local min      <const> = math.min
local max      <const> = math.max

-- Graphics
local pushContext    <const> = Graphics.pushContext
local popContext     <const> = Graphics.popContext
local setColor       <const> = Graphics.setColor
local setDrawMode    <const> = Graphics.setImageDrawMode
local newImage       <const> = Graphics.image.new
local setClipRect    <const> = Graphics.setClipRect
local fillRect       <const> = Graphics.fillRect
local drawTextInRect <const> = Graphics.drawTextInRect

-- Config
local getConfigValue <const> = roxy.Configuration.get

-- Asset / cache
local getIsPoolRegistered <const> = Assets.getIsPoolRegistered
local registerPool        <const> = Assets.registerPool
local getAsset            <const> = Assets.getAsset
local recycleAsset        <const> = Assets.recycleAsset
local isAssetCached       <const> = Cache.getIsAssetCached
local getCachedAsset      <const> = Cache.getCachedAsset
local cacheAsset          <const> = Cache.cacheAsset
local evictAsset          <const> = Cache.evictAsset

-- Input
local addHandler    <const> = roxy.Input.addHandler
local removeHandler <const> = roxy.Input.removeHandler

-- Text / theme
local getFontOffset  <const> = Text.getFontOffset
local getFontHash    <const> = Text.getFontHash
local getScheme      <const> = roxy.Theme.getScheme

-- UI
local newRectImage <const> = roxy.UI.newRectImage

-- ---------------------------------- --
-- ! Imports                          --
-- ---------------------------------- --

import "libraries/roxy-dialogue/core/RoxyDialogueIndicator"
import "libraries/roxy-dialogue/core/RoxyPager"
import "libraries/roxy-dialogue/core/RoxyTypewriter"

-- ---------------------------------- --
-- ! Constants                        --
-- ---------------------------------- --

-- Graphics modes
local drawModeCopy   <const> = Graphics.kDrawModeCopy
local colorClear     <const> = Graphics.kColorClear
local colorWhite     <const> = Graphics.kColorWhite

-- Asset / cache
local DIALOGUE_IMG_POOL <const> = "dialogueImage"      -- Pool for dialogue image assets
local _cachePrefix      <const> = "RoxyDialoguePages:" -- Internal cache key prefix

-- Layout
local DEFAULT_TYPING_SPEED    <const> = 90   -- Characters per second
local FAST_TYPING_MULTIPLIER  <const> = 20   -- Multiplier for fast typing mode
local DEFAULT_NUMBER_OF_LINES <const> = 4    -- Default lines per dialogue box
local DEFAULT_LEADING         <const> = 2    -- Line spacing
local DEFAULT_CORNER_RADIUS   <const> = 0    -- Corner radius for dialogue box
local DEFAULT_PADDING         <const> = 10   -- Horizontal and vertical padding
local DEFAULT_Z_INDEX         <const> = 1000 -- Default z-index for dialogue UI

-- Text
local MINIMUM_TEXT_HEIGHT <const> = 1 -- Minimum height for dialogue sprites
local MINIMUM_TEXT_WIDTH  <const> = 1 -- Minimum width for text rendering

-- Display
local DISPLAY_WIDTH  <const> = roxy.Graphics.displayWidth
local DISPLAY_HEIGHT <const> = roxy.Graphics.displayHeight

-- Input
local makeInputHandler <const> = import "libraries/roxy-dialogue/core/RoxyDialogueInput"

-- ---------------------------------- --
-- ! Register Assets                  --
-- ---------------------------------- --

-- Ensure "dialogueImage" asset pool exists (safe to call repeatedly)
if roxy and Assets and not getIsPoolRegistered("dialogueImage") then
  registerPool(
    "dialogueImage",
    3,
    function() return newImage(DISPLAY_WIDTH, DISPLAY_HEIGHT) end,
    { maxSize = 7 }
  )
end

-- ---------------------------------- --
-- ! Class                            --
-- ---------------------------------- --

class("RoxyDialogue").extends(RoxySprite)

-- ! Constructor
function RoxyDialogue:init(text, props)

  RoxyDialogue.super.init(self)
  props = props or {}
  text  = text or ""

  local defaultTypingSpeed = getConfigValue("defaultTypingSpeed") or DEFAULT_TYPING_SPEED
  local fastTypingMultiplier = getConfigValue("fastTypingMultiplier") or FAST_TYPING_MULTIPLIER

  -- Font
  self.font       = props.font      or Text.font
  self.alignment  = props.alignment or Text.ALIGN_LEFT
  self.fontOffset = getFontOffset(self.font) or 0

  -- Spacing
  self.numberOfLines     = props.numberOfLines or DEFAULT_NUMBER_OF_LINES
  self.leading           = props.leading or DEFAULT_LEADING
  self.paddingHorizontal = props.paddingHorizontal or DEFAULT_PADDING
  self.paddingVertical   = props.paddingVertical or DEFAULT_PADDING

  -- Layout
  local totalHorizontalPadding = self.paddingHorizontal * 2
  local totalVerticalPadding   = self.paddingVertical * 2
  local availableWidth  = (props.width  or DISPLAY_WIDTH) - totalHorizontalPadding
  local availableHeight = (props.height or DISPLAY_HEIGHT) - totalVerticalPadding
  local maxTextWidth  = max(availableWidth, MINIMUM_TEXT_WIDTH)
  local maxTextHeight = max(availableHeight, MINIMUM_TEXT_HEIGHT)

  -- Text width / height
  local textWidth = self.font:getTextWidth(text)
  self.textWidth = min(textWidth, maxTextWidth)

  local fontHeight = self.font:getHeight()
  self.textHeight = min(
    ((fontHeight * self.numberOfLines) + ((self.numberOfLines - 1) * self.leading)),
    maxTextHeight
  )

  -- Final sprite size and position
  self.spriteWidth = min(
    (props.width or (self.textWidth + totalHorizontalPadding)),
    DISPLAY_WIDTH
  )
  self.spriteHeight = min(
    (props.height or (self.textHeight + totalVerticalPadding)),
    DISPLAY_HEIGHT
  )
  self.dialogueX = props.x or ((DISPLAY_WIDTH - self.spriteWidth) * 0.5)
  self.dialogueY = props.y or ((DISPLAY_HEIGHT - self.spriteHeight) * 0.5)
  self.dialogueZIndex = props.zIndex or DEFAULT_Z_INDEX

  -- Styling
  self.hasBackground = props.hasBackground ~= false
  self.colorScheme   = getScheme(props.color or props.foreground, props.background)
  self.cornerRadius  = props.cornerRadius or DEFAULT_CORNER_RADIUS
  self.instant       = props.instant or false

  -- Background or text image buffer
  if self.hasBackground then
    -- TODO: You can store `self.background` in the object pool and simply get it here
    self.background = newRectImage(
      self.spriteWidth,
      self.spriteHeight,
      self.colorScheme.normalColor,
      self.cornerRadius
    )
  else
    -- TODO: You can store `self.textImage` in the object pool and simply get it here
    self.textImage = getAsset("dialogueImage") or newImage(self.spriteWidth, self.spriteHeight)
  end

  -- Page image cache
  self._pageCache = {
    get = function(_, key) return getCachedAsset("RoxyDialoguePages:" .. key) end,
    put = function(_, key, asset)
      return cacheAsset("RoxyDialoguePages:" .. key, function() return asset end)
    end,
    evict = function(_, key) return evictAsset("RoxyDialoguePages:" .. key) end,
  }

  -- Incremental draw image
  self._typingBuffer = self.textImage or newImage(self.spriteWidth, self.spriteHeight)

  -- Page and typewriter logic
  self.pager = Pager(
    text,
    self.font,
    self.textWidth,
    self.numberOfLines,
    self.leading
  )
  self.typewriter = Typewriter(self.pager, {
    baseSpeed      = props.typingSpeed or defaultTypingSpeed,
    fastMultiplier = props.fastMultiplier or fastTypingMultiplier,
    fastSpeed      = props.fastTypingSpeed,
    instant        = self.instant,
  })

  -- State
  self._prevFragment = "" -- keeps delta for incremental draw
  self._finishedImage = nil

  -- Sprite setup
  self:setCenter(0, 0)
  self:setSize(self.spriteWidth, self.spriteHeight)
  self:setZIndex(self.dialogueZIndex)
  self:moveTo(self.dialogueX, self.dialogueY)

  -- Next page indicator
  self.indicatorX = props.indicatorX
  self.indicatorY = props.indicatorY
  self.indicator = RoxyDialogueIndicator(props, self.dialogueZIndex)
  self:updateNextPageIndicator()

  -- Input setup
  self._inputHandler       = props.inputHandler
  self._inputHandlerPushed = false
  self.modal              = props.modal ~= false
  self.onDismissCallback  = props.onDismiss
  if self.onDismissCallback and type(self.onDismissCallback) ~= "function" then
    logWarn("RoxyDialogue: 'onDismiss' should be a function. Ignoring.")
    self.onDismissCallback = nil
  end

  -- Activate
  self.isActive = props.isActive or false
  if self.isActive then self:startTypewriter() end
end

-- ---------------------------------- --
-- ! Helpers                          --
-- ---------------------------------- --

-- ! Typing Buffer
-- Allocates and clears a new image buffer for typing
local function _newBuffer(self)
  local image = getAsset(DIALOGUE_IMG_POOL) or newImage(self.spriteWidth, self.spriteHeight)

  pushContext(image)
    setColor(colorClear)
    fillRect(0, 0, self.spriteWidth, self.spriteHeight)
  popContext()

  return image
end

-- ---------------------------------- --
-- ! Internal Methods                 --
-- ---------------------------------- --

-- ! Start Typewriter
-- Starts (or restarts) the typewriter animation
function RoxyDialogue:startTypewriter()
  -- recycle previous buffer (if any) before allocating a new one
  if self._typingBuffer then
    recycleAsset(DIALOGUE_IMG_POOL, self._typingBuffer)
    self._typingBuffer = nil
  end

  self._typingBuffer  = _newBuffer(self)
  self._finishedImage = nil
  self._prevFragment  = ""

  self.typewriter:restart()
  local fragment, done = self.typewriter:update(0)

  if fragment then self:renderPage(fragment, done) end
  self:updateNextPageIndicator()
end

-- ! Render Page
-- Draws current text fragment to buffer and caches finished pages
function RoxyDialogue:renderPage(fragment, isComplete)
  if not fragment then return self end
  local buffer = self._typingBuffer

  -- (1)  Draw COMPLETE fragment each tick (overwrite mode is fastest)
  pushContext(buffer)
    setDrawMode(self.colorScheme.invertedFill)
    drawTextInRect(
      fragment,
      self.paddingHorizontal,
      self.paddingVertical - self.fontOffset,
      self.textWidth,
      self.textHeight,
      self.leading,
      "…",
      self.alignment,
      self.font
    )
    setDrawMode(drawModeCopy)
  popContext()

  -- (2) Commit finished page to LRU cache exactly once
  if isComplete then
    -- Generate a unique key based on font, layout, and text content
    local key = concat{getFontHash(self.font) or tostring(self.font), ":", self.textWidth, ":", self.leading, ":", self.alignment, ":", fragment}
    local fullKey = _cachePrefix .. key

    if not isAssetCached(fullKey) then
      cacheAsset(fullKey, function() return buffer end)
    else
      recycleAsset(DIALOGUE_IMG_POOL, buffer)
    end

    self._finishedImage = getCachedAsset(fullKey)
    self._typingBuffer  = _newBuffer(self)
  end

  self._prevFragment = fragment
  self:markDirty()
  return self
end

-- ! Update Next-Page Indicator
-- Updates the visibility and position of the next-page indicator
function RoxyDialogue:updateNextPageIndicator()
  local indicatorWidth, indicatorHeight = self.indicator.indicatorWidth, self.indicator.indicatorHeight
  local localX = self.indicatorX or (self.spriteWidth - indicatorWidth) * 0.5
  local localY = self.indicatorY or self.spriteHeight - indicatorHeight * 0.5
  local newX = self.dialogueX + localX
  local newY = self.dialogueY + localY
  self.indicator:updateVisibility(
    self.isActive,
    self.typewriter:isComplete(),
    self.pager:isLast(),
    newX, newY
  )
end

-- ---------------------------------- --
-- ! Public API                       --
-- ---------------------------------- --

-- ! Activate
-- Adds dialogue to scene and sets up input handling according to modal setting
function RoxyDialogue:activate(pushHandler, handlerOverride)
  if self.isActive then return self end

  self:add()
  self.isActive = true

  if pushHandler ~= false then
    local handlerSpec = handlerOverride or self._inputHandler
    local handler

    if handlerSpec then
      --#DEBUG START
      if type(handlerSpec) ~= "function" and type(handlerSpec) ~= "table" then
        logWarn("RoxyDialogue: Invalid inputHandler type (" .. type(handlerSpec) .. "). Expected function or table.")
      end
      --#DEBUG END

      handler = (type(handlerSpec) == "function") and handlerSpec(self) or handlerSpec
      self._inputHandler = handlerSpec
    end

    -- Defensive: always try to get a handler, fallback to default if needed
    if not handler then
      handler = makeInputHandler and makeInputHandler(self) or {}
    end

    -- Apply modal: fill all keys if self.modal
    if self.modal and roxy.Input.makeModalHandler then
      handler = roxy.Input.makeModalHandler(handler)
    end

    if handler then
      addHandler(self, handler, 100)
      self._inputHandlerPushed = true
    else --#DEBUG
      logWarn("RoxyDialogue: Failed to construct valid input handler. Skipping input registration.") --#DEBUG
    end
  end

  self:startTypewriter()
  return self
end

-- ! Deactivate
-- Removes dialogue from scene and resets input
function RoxyDialogue:deactivate()
  if self._inputHandlerPushed then
    removeHandler(self)
    self._inputHandlerPushed = false
  end

  self.isActive = false
  if self.indicator then
    self.indicator:remove()
    self.indicator = nil
  end
  self:remove()
  self:markDirty()

  if self.onDismissCallback then
    self.onDismissCallback()
  end

  return self
end

-- ! Restart
-- Restarts the typewriter and pager
function RoxyDialogue:restart()
  self.pager:restart()
  self:startTypewriter()
  return self
end

-- ! Update
function RoxyDialogue:update()
  RoxyDialogue.super.update(self)
  if not self.isActive or self.typewriter:isComplete() then return end

  local fragment, done = self.typewriter:update(roxy.deltaTime)
  if fragment ~= self._prevFragment or done then
    self:renderPage(fragment, done)
  end

  if done then self:updateNextPageIndicator() end
end


-- ! Draw
function RoxyDialogue:draw()
  -- Draw background only if it exists
  if self.hasBackground then self.background:draw(0, 0) end

  -- Fast single branch for text (choose buffer based on completion)
  local image = self.typewriter:isComplete() and self._finishedImage or self._typingBuffer
  if image then image:draw(0, 0) end
end
