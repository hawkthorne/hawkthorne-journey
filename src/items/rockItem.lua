-----------------------------------------------
-- rockItem.lua
-- Represents a rock when it is in the players inventory
-- Created by HazardousPeach
-----------------------------------------------


local RockItem = {}
RockItem.__index = RockItem
RockItem.rockItem = true

local RockItemImage = love.graphics.newImage('images/rock_item.png')

---
-- Creates a new rock item object
-- @return the rock item object created
function RockItem.new()
   local rockItem = {}
   setmetatable(rockItem, RockItem)
   rockItem.image = RockItemImage
   rockItem.type = 'Material'
   return rockItem
end

---
-- Draws the rock to the screen
-- @return nil
function RockItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
end

return RockItem