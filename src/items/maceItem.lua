-----------------------------------------------
-- maceItem.lua
-- The code for the mace, when it is in the player's inventory.
-- Created by NimbusBP1729
-----------------------------------------------
local Item = require 'items/Item'

local MyItem  = {}
MyItem.__index = MyItem

function MyItem.new()

    local node = {
       type = 'Weapon',
       isHolding = false,
       weapontype = "mace"
    }
    return Item.new(node)
end

return MyItem