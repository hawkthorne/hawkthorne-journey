-----------------------------------------------
-- emotion.lua
-- Represents a generic emotion that is displayed over a character
-- Created by Niamu
-----------------------------------------------

local Emotion = {}
Emotion.__index = Emotion

function Emotion.new(npc, name)
  local emotion = {}
  setmetatable(emotion, Emotion)

  emotion.name = name

  if emotion.name ~= nil then
    emotion.sheet = love.graphics.newImage('images/emotions/'..emotion.name..'.png')
    emotion.width = emotion.sheet:getWidth()
    emotion.height = emotion.sheet:getHeight()
    
    emotion.sheet:setFilter('nearest', 'nearest')
  end

  return emotion
end

---
-- Draws the Emotion to the screen
-- @return nil
function Emotion:draw(npc)
  if self.sheet ~= nil and npc.state ~= 'hidden' then
    local x = npc.position.x + (npc.width / 2) - (self.width / 2)
    local y = npc.position.y - self.height
    love.graphics.draw( self.sheet, x, y )
  end
end

return Emotion
