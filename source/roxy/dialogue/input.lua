-- RoxyDialogueInput

return function(self)
  if self._inputHandler then return self._inputHandler end

  self._inputHandler = {

    -- ------------------------------ --
    -- ! A Button                     --
    -- ------------------------------ --

    -- Advances typewriter or moves to next page.
    AButtonDown = function()
      if not self.typewriter:isComplete() then
        -- Accelerate typewriter animation
        self.typewriter:fastForward()
      elseif self.pager:next() then
        self:startTypewriter()
      end

      self:updateNextPageIndicator()
    end,

    -- ------------------------------ --
    -- ! B Button                     --
    -- ------------------------------ --

    -- Deactivates the dialogue.
    BButtonDown = function()
      self:deactivate()
    end,

    -- ------------------------------ --
    -- ! Up Button                    --
    -- ------------------------------ --

    -- Moves to the previous page if possible.
    upButtonDown = function()
      if self.pager:prev() then
        self:startTypewriter()
      end

      self:updateNextPageIndicator()
    end,

    -- ------------------------------ --
    -- ! Down Button                  --
    -- ------------------------------ --

    -- Advances typewriter or moves to next page.
    downButtonDown = function()
      if not self.typewriter:isComplete() then
        self.typewriter:fastForward()
      elseif self.pager:next() then
        self:startTypewriter()
      end

      self:updateNextPageIndicator()
    end,
  }

  return self._inputHandler
end
