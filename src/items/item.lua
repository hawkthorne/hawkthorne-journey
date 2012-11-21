-----------------------------------------------
-- item.lua
-- The code for an object, when it in the players inventory.
-- Created by HazardousPeach and NimbusBP1729
-----------------------------------------------
local GS = require 'vendor/gamestate'

local Item = {}
Item.__index = Item
Item.isItem = true

Item.MaxItems = math.huge

function Item.new(node)
    local item = {}
    setmetatable(item, Item)
    item.name = node.name
    item.type = node.type
    item.props = node
    item.image = love.graphics.newImage( 'images/' .. item.type .. 's/' .. item.name .. '.png' )
    item.image_q = love.graphics.newQuad( 0, 24, 15, 15, item.image:getWidth(),item.image:getHeight() )
    item.MaxItems = node.MAX_ITEMS or math.huge
    item.quantity = node.quantity or 1
    item.isHolding = node.isHolding
    return item
end

---
-- Draws the item in the inventory
-- @param position the location in the inventory
-- @return nil
function Item:draw(position)
    love.graphics.drawq(self.image, self.image_q, position.x, position.y)
    if self.type ~= "material" then
       love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
    end
end

function Item:use(player)
    if self.props.use then
        self.props.use(player,self)
    end
end

---
-- Returns whether or not the given item can be merged or partially merged with this one.
-- @param otherItem the item that the client wants to merge with this one.
-- @returns whether otherItem can merge with self
function Item:mergible(otherItem)
    if self.name ~= otherItem.name or 
       self.type ~= otherItem.type then
        return false 
    end
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
