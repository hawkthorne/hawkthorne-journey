-----------------------------------------------
-- maceItem.lua
-- The code for the mace, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local Global = require 'global'
local Item = require 'items/item'
local MaceItem = {}
MaceItem.__index = MaceItem
MaceItem.isMaceItem = true

local MaceItemImage = love.graphics.newImage('images/mace_item.png')
local Mace = require 'nodes/mace'

local GS = require 'vendor/gamestate'

---
-- Creates a new Mace item object
-- @return the Mace item object created
function MaceItem.new()
   local maceItem = {}
   setmetatable(maceItem, MaceItem)
   maceItem = Global.inherits(maceItem,Item)
   maceItem.image = MaceItemImage
   maceItem.type = 'Weapon'
   maceItem.quantity = 1
   maceItem.isHolding = false
   maceItem.nodeType = "mace"
   maceItem.parentNode = Mace

   return maceItem
end

return MaceItem
