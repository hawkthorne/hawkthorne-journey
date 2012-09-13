-----------------------------------------------
-- stickItem.lua
-- Represents a stick when it is in the players inventory
-- Created by HazardousPeach
-----------------------------------------------

local StickItem = {}
StickItem.__index = StickItem
StickItem.stickItem = true

local StickItemImage = love.graphics.newImage('images/stick_item.png')

---
-- Creates a new stick item object
-- @return the stick item object created
function StickItem.new()
   local stickItem = {}
   setmetatable(stickItem, StickItem)
   stickItem.image = StickItemImage
   stickItem.type = 'Material'
   stickItem.name = 'stick'
   return stickItem
end

---
-- Draws the stick to the screen
-- @return nil
function StickItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
end

return StickItem