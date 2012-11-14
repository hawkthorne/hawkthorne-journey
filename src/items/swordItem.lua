-----------------------------------------------
-- swordItem.lua
-- The code for the sword, when it is in the player's inventory.
-- Created by NimbusBP1729
-----------------------------------------------

local Item = require 'items/Item'

local MyItem  = {}
MyItem.__index = MyItem

function MyItem.new()

    local node = {
        image = love.graphics.newImage('images/sword_item.png'),
        type = 'Weapon',
        isHolding = false,
        nodeType = "sword"
    }
    return Item.new(node)
end

return MyItem
