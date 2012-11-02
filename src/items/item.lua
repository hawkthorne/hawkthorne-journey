-----------------------------------------------
-- item.lua
-- The code for an object, when it in the players inventory.
-- Created by HazardousPeach and NimbusBP1729
-----------------------------------------------
local GS = require 'vendor/gamestate'

local Item = {}
Item.__index = Item
Item.Item = true

Item.MaxItems = math.huge


--takes out the bombs
function Item:use(player)
    
    --may be faulty for autouse
    player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)

    local weaponNode = { 
                        name = "",
                        x = player.position.x,
                        y = player.position.y,
                        width = 50,
                        height = 50,
                        type = self.nodeType,
                        properties = {
                            ["foreground"] = "false",
                        },
                       }
    local weapon = self.parentNode.new(weaponNode, GS.currentState().collider,player,self)
    if not player.currently_held then
        player.currently_held = weapon
    end
    table.insert(GS.currentState().nodes, weapon)
end

---
-- Draws the Throwing Knife to the screen
-- @return nil
function Item:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end


---
-- Returns whether or not the given item can be merged or partially merged with this one.
-- @param otherItem the item that the client wants to merge with this one.
-- @returns whether the other knife and this knife can merge.
function Item:mergible(otherItem)
    if self.nodeType ~= otherItem.nodeType then return false end
    if self.quantity >= self.MaxItems then return false end
    return true
end

---
-- Merges the two knives
-- @param otherItem the knife to merge with.
-- @returns true if the item could be completely merged, false if it could not be merged or could only be partially merged.
function Item:merge(otherItem)
    if self.quantity + otherItem.quantity <= self.MaxItems then 
        self.quantity = self.quantity + otherItem.quantity
        return true
    else
        otherItem.quantity = (otherItem.quantity + self.quantity) - self.MaxItems
        self.quantity = self.MaxItems
        return false
    end
end

return Item
