-----------------------------------------------
-- leafItem.lua
-- Represents a leaf when it is in the players inventory
-- Created by HazardousPeach
-----------------------------------------------


local LeafItem = {}
LeafItem.__index = LeafItem
LeafItem.leafItem = true

local LeafItemImage = love.graphics.newImage('images/leaf_item.png')

---
-- Creates a new leaf item object
-- @return the leaf item object created
function LeafItem.new()
   local leafItem = {}
   setmetatable(leafItem, LeafItem)
   leafItem.type = 'Material'
   leafItem.name = 'leaf'
   return leafItem
end

---
-- Draws the rock to the screen
-- @return nil
function LeafItem:draw(position)
   love.graphics.drawq(LeafItemImage, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
end

return LeafItem