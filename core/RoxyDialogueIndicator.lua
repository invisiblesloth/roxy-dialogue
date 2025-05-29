-- RoxyDialogueIndicator

local DEFAULT_INDICATOR_PATH           <const> = "libraries/roxy-dialogue/assets/images/pagination"
local DEFAULT_INDICATOR_FRAME_DURATION <const> = 0.2 -- Seconds between indicator frames
local INDICATOR_SIZE                   <const> = 20
local DEFAULT_INDICATOR_Z_INDEX_OFFSET <const> = 1   -- Default z-index bump

class("RoxyDialogueIndicator").extends(RoxySprite)

-- ! Initialize
function RoxyDialogueIndicator:init(props, parentZIndex)
  -- Prepare sprite options for RoxySprite
  local spriteOptions = {
    view          = (props and props.nextPageIndicatorImage) or DEFAULT_INDICATOR_PATH,
    isSheet       = true,
    singleAnim    = true,
    singleAnimLoop = true,
    frameDuration = (props and props.nextPageIndicatorFrameDuration) or DEFAULT_INDICATOR_FRAME_DURATION
  }

  RoxyDialogueIndicator.super.init(self, spriteOptions)

  local size = (props and props.nextPageIndicatorSize) or INDICATOR_SIZE

  -- Get the actual sprite size (from image or fallback)
  local width, height = self:getSize()
  self.indicatorWidth =  (props and props.nextPageIndicatorWidth)
    or (width  > 0 and width)
    or INDICATOR_SIZE
  self.indicatorHeight = (props and props.nextPageIndicatorHeight)
    or (height > 0 and height)
    or INDICATOR_SIZE

  self:setCenter(0, 0)
  self:setSize(self.indicatorWidth, self.indicatorHeight)
  self:setZIndex((parentZIndex or 0) + ((props and props.zIndexOffset)
    or DEFAULT_INDICATOR_Z_INDEX_OFFSET))
end

-- ! Update Visibility
function RoxyDialogueIndicator:updateVisibility(isActive, typingComplete, isLastPage, x, y, height)
  local shouldShow = isActive and typingComplete and not isLastPage
  if shouldShow and not self:isAdded() then
    self:moveTo(x, y)
    self:add()
    if self.isRoxySprite and (self.animation or self.simpleAnim) then
      self:play()
    end
  elseif not shouldShow and self:isAdded() then
    self:remove()
  end
end
