----------------------------------------------------------------------
-- characterstrip.lua
-- A single colored strip, on which a character appears for selection.
-- Created by tjvezina
----------------------------------------------------------------------
local window = require 'window'

local CharacterStrip = {}
CharacterStrip.__index = CharacterStrip


local stripSize = 35   -- Thickness of the strip
local moveSize = 300    -- Pixels travelled from ratio 0 to 1
local moveSpeed = 5.0    -- Slide speed multiplier
-- The different colored bars on the strip appear at these intervals
local colorSpacing = { 140, 160, 180, 200, 260 }

-- Hawkthorne Colors (As arranged on-screen):
-- NOTE: Each strips 2nd color is calculated by (220-r, 220-g, 220-b)
--    ( 81,  73, 149) | (149, 214, 200)
--   (150, 221, 149)  |  (134,  60, 133)
--  (200, 209, 149)   |   (171,  98, 109)
-- (173, 135, 158)    |    ( 80,  80,  80)

function CharacterStrip.new(r, g, b)
  local new = {}
  setmetatable(new, CharacterStrip)

  new.x = 0
  new.y = 0
  new.flip = false

  new.ratio = 0
  new.slideOut = false

  new.color1 = { r = r, g = g, b = b }
  new.color2 = { r = 220-r, g = 220-g, b = 220-b }

  new.stencilFunc = function( this )
    love.graphics.rectangle('fill', this.x - ( this.flip and 0 or (window.width * 0.5) ), this.y, (window.width * 0.5), stripSize)
    love.graphics.rectangle('fill', this.x - ( this.flip and 0 or stripSize ), this.y + stripSize,
      stripSize, math.max(moveSize * this.ratio - stripSize, 0))
  end

  return new
end

function CharacterStrip:getCharacterPos()
  local x = self.x + (self.flip and 44 or -44) - self:getOffset() / 1.5
  local y = self.y

  if not self.flip then
    local limit = self.x + 10
    if x > limit then
      y = y + (x - limit)
      x = limit
    end
  else
    local limit = self.x - 10
    if x < limit then
      y = y + (limit - x)
      x = limit
    end
  end

  return x, y
end

function CharacterStrip:draw()

  love.graphics.stencil(function() self.stencilFunc(self) end) 
  love.graphics.setStencilTest("greater", 0)

  for i, offset in ipairs(colorSpacing) do
    love.graphics.setColor( self:getColor((i-1) / (#colorSpacing-1)) )
    love.graphics.polygon('fill', self:getPolyVerts(i))
  end

  if self.selected and self.ratio == 0 then -- Father forgive me for I have sinned
    local flipped = self.flip and 1 or -1
    local x1 = -self:getOffset() + self.x
    local y1 = self.y
    local x2 = -self:getOffset() + self.x + colorSpacing[5] * flipped
    local y2 = self.y

    local x3 = x2 + stripSize * flipped
    local y3 = y2 + stripSize
    local x4 = x1 + stripSize * flipped
    local y4 = y1 + stripSize

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.polygon('line', x1, y1, x2, y2, x3, y3, x4, y4)
    -- I know not what I do
  end

  love.graphics.setStencilTest()
end

local time = 0
function CharacterStrip:update(dt,ready)
  self.ratio = self.ratio + dt * moveSpeed
  if not self.slideOut then
    self.ratio = math.min(self.ratio, 0)
  end
end

function CharacterStrip:getPolyVerts(segment)
  local offset = -self:getOffset()

  if self.flip then
    return offset + self.x + (colorSpacing[segment-1] or 0),
           self.y,
           offset + self.x + colorSpacing[segment],
           self.y,
           offset + self.x + colorSpacing[segment] + moveSize,
           self.y + moveSize,
           offset + self.x + (colorSpacing[segment-1] or 0) + moveSize,
           self.y + moveSize
  else
    return offset + self.x - (colorSpacing[segment-1] or 0),
           self.y,
           offset + self.x - (colorSpacing[segment-1] or 0) - moveSize,
           self.y + moveSize,
           offset + self.x - colorSpacing[segment] - moveSize,
           self.y + moveSize,
           offset + self.x - colorSpacing[segment],
           self.y
  end
end

function CharacterStrip:getColor(ratio)
  assert(ratio >= 0 and ratio <= 1, "Color ratio must be between 0 and 1.")

  if ratio == 0 then return self.color1.r, self.color1.g, self.color1.b,255 end
  if ratio == 1 then return self.color2.r, self.color2.g, self.color2.b,255 end

  return self.color1.r + ( ( self.color2.r - self.color1.r ) * ratio ),
         self.color1.g + ( ( self.color2.g - self.color1.g ) * ratio ),
         self.color1.b + ( ( self.color2.b - self.color1.b ) * ratio ),
         255
end

function CharacterStrip:getOffset()
  return ( (self.flip and -moveSize or moveSize) * -self.ratio ) + (self.flip and -1 or 1)
end

return CharacterStrip
