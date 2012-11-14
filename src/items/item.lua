-----------------------------------------------
-- item.lua
-- The code for an object, when it in the players inventory.
-- Created by HazardousPeach and NimbusBP1729
-----------------------------------------------
local GS = require 'vendor/gamestate'
local Weapon = require 'nodes/weapon'

local Item = {}
Item.__index = Item
Item.isItem = true

Item.MaxItems = math.huge

function Item.new(itemNode)
    local item = {}
    setmetatable(item, Item)

    item.image = love.graphics.newImage('images/weapons/'..itemNode.nodeType..'_item.png')
    item.type = itemNode.type
    item.quantity = itemNode.quantity or 1
    item.isHolding = itemNode.isHolding
    item.nodeType = itemNode.nodeType
    item.name = itemNode.nodeType
    return item
end

--takes out the inventory item
function Item:use(player)
    
    player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)

    local weaponNode = { 
                        name = "",
                        x = player.position.x,
                        y = player.position.y,
                        width = 50,
                        height = 50,
                        type = self.type,
                        properties = {
                            ["foreground"] = "false",
                            ["nodeType"] = self.nodeType,
                        },
                       }
    local weapon = Weapon.new(weaponNode, GS.currentState().collider,player,self)
    if not player.currently_held then
        player.currently_held = weapon
        player:setSpriteStates('wielding')
    end
    table.insert(GS.currentState().nodes, weapon)
end

---
-- Draws the item in the inventory
-- @param position the location in the inventory
-- @return nil
function Item:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end


---
-- Returns whether or not the given item can be merged or partially merged with this one.
-- @param otherItem the item that the client wants to merge with this one.
-- @returns whether otherItem can merge with self
function Item:mergible(otherItem)
    if self.name ~= otherItem.name then return false end
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
