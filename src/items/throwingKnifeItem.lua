-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the throwing knife, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------

local TKnifeItem = {}
TKnifeItem.__index = TKnifeItem
TKnifeItem.tKnifeItem = true

local TKnifeItemImage = love.graphics.newImage('images/throwing_knives_item.png')
local FlyingKnife = require 'nodes/flying_knife'

local GS = require 'vendor/gamestate'

MaxKnives = 8

---
-- Creates a new Throwing Knife item object
-- @return the Throwing Knife item object created
function TKnifeItem.new()
   local tKnifeItem = {}
   setmetatable(tKnifeItem, TKnifeItem)
   tKnifeItem.type = 'Weapon'
   tKnifeItem.quantity = 4
   tKnifeItem.name = "throwingKnife"
   return tKnifeItem
end

---
-- Draws the Throwing Knife to the screen
-- @return nil
function TKnifeItem:draw(position)
   love.graphics.drawq(TKnifeItemImage, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end

---
-- Throws one knife from the player
-- @param player the player that is throwing
function TKnifeItem:use(player)
    if self.quantity < 2 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
    end
    self.quantity = self.quantity - 1
    local playerDirection = 1
    if player.direction == "left" then playerDirection = -1 end
    local knifeX = player.position.x + (player.width / 2) + (15 * playerDirection)
    local knifeNode = { 
                        name = "", 
                        x = knifeX, 
                        y = player.position.y + (player.height / 1.5),
                        width = 20,
                        height = 7,
                        type = "flying_knife",
                        properties = {
                          ["velocityX"] = (7 * playerDirection) .. "",
                          ["velocityY"] = "0",
                        },
                       }
    local knife = FlyingKnife.new(knifeNode, GS.currentState().collider)
    table.insert(GS.currentState().nodes, knife)
end

---
-- Returns whether or not the given item can be merged or partially merged with this one.
-- @param otherKnife the item that the client wants to merge with this one.
-- @returns whether the other knife and this knife can merge.
function TKnifeItem:mergible(otherKnife)
    if self.quantity >= MaxKnives then return false end
    return true
end

---
-- Merges the two knives
-- @param otherKnife the knife to merge with.
-- @returns true if the item could be completely merged, false if it could not be merged or could only be partially merged.
function TKnifeItem:merge(otherknife)
    if self.quantity + otherknife.quantity <= MaxKnives then 
        self.quantity = self.quantity + otherknife.quantity
        return true
    else
        otherknife.quantity = (otherknife.quantity + self.quantity) - MaxKnives
        self.quantity = MaxKnives
        return false
    end
end

return TKnifeItem
