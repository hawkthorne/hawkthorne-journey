-----------------------------------------------
-- maletItem.lua
-- The code for the mace, when it is in the player's inventory.
-- Created by NimbusBP1729
-----------------------------------------------

local Item = require 'items/Item'

local MyItem  = {}
MyItem.__index = MyItem

function MyItem.new()

    local node = {
        image = love.graphics.newImage('images/mallet_item.png'),
        type = 'Weapon',
        isHolding = false,
        nodeType = "mallet"
    }
    return Item.new(node)
end

return MyItem