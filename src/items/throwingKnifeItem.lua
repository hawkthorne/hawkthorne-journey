-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the throwing knife, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------

local TKnifeItem = {}
TKnifeItem.__index = TKnifeItem
TKnifeItem.tKnifeItem = true

local TKnifeItemImage = love.graphics.newImage('images/throwing_knives_item.png')

---
-- Creates a new Throwing Knife item object
-- @return the Throwing Knife item object created
function TKnifeItem.new()
   local tKnifeItem = {}
   setmetatable(tKnifeItem, TKnifeItem)
   tKnifeItem.image = TKnifeItemImage
   tKnifeItem.type = 'Weapon'
   tKnifeItem.quantity = 4
   tKnifeItem.deleteFlag = false
   return tKnifeItem
end

---
-- Draws the Throwing Knife to the screen
-- @return nil
function TKnifeItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.3, 0.3)
end

---
-- Throws one knife from the player
-- @param player the player that is throwing
function TKnifeItem:use(player)
end

return TKnifeItem