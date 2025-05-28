-- Pager

-- ---------------------------------- --
-- ! Module & SDK Aliases             --
-- ---------------------------------- --

local pd     <const> = playdate
local Object <const> = pd.object

-- ---------------------------------- --
-- ! Performance-Oriented Aliases     --
-- ---------------------------------- --

local ceil    <const> = math.ceil
local max     <const> = math.max
local min     <const> = math.min
local reserve <const> = table.reserve -- may be nil on SDK < 2.0
local concat  <const> = table.concat
local wrap    <const> = roxy.Text.wrap

-- ---------------------------------- --
-- ! Constants                        --
-- ---------------------------------- --

local DEFAULT_NUMBER_OF_LINES <const> = 4
local DEFAULT_LEADING         <const> = 2 -- Pixels between lines
local FIRST_PAGE_INDEX        <const> = 1 -- Initial page index
local DISPLAY_WIDTH           <const> = roxy.Graphics.displayWidth

class("Pager").extends(Object)

-- ! Initialize
function Pager:init(text, font, textWidth, linesPerPage, leading)
  Pager.super.init(self)

  text = text or ""

  self.font = font or roxy.Text.font
  self.textWidth = min(textWidth or self.font:getTextWidth(text), DISPLAY_WIDTH)
  self.linesPerPage = linesPerPage or DEFAULT_NUMBER_OF_LINES
  self.leading = leading or DEFAULT_LEADING

  self:setText(text)
end

-- ! Paginate
function Pager:paginate()
  local lines = wrap(self._text, self.font, self.textWidth)

  self._pages = {}
  local totalPages = ceil(#lines / self.linesPerPage)
  if reserve then reserve(self._pages, totalPages) end -- safe on all SDKs

  for i = 1, #lines, self.linesPerPage do
    local j = min(i + self.linesPerPage - 1, #lines)
    self._pages[#self._pages + 1] = concat(lines, "\n", i, j)
  end

  self.currentPage = FIRST_PAGE_INDEX
  self.pageCount   = max(1, #self._pages)
end

-- ! Set Text
function Pager:setText(text)
  self._text = (type(text) == "string") and text or ""
  self:paginate()
end

-- ! Get Current Page
function Pager:getCurrent()
  return self._pages[self.currentPage] or ""
end

-- ! Next Page
function Pager:next()
  if self.currentPage < self.pageCount then
    self.currentPage += 1
    return true
  end
  return false
end

-- ! Previous Page
function Pager:prev()
  if self.currentPage > FIRST_PAGE_INDEX then
    self.currentPage -= 1
    return true
  end
  return false
end

-- ! Is Last Page
function Pager:isLast()
  return self.currentPage >= self.pageCount
end

-- ! Restart
function Pager:restart()
  self.currentPage = FIRST_PAGE_INDEX
end

-- ! Reset
function Pager:reset()
  self:setText("")
end
