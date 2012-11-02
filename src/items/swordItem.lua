-----------------------------------------------
-- swordItem.lua
-- The code for the sword, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local utils = require 'utils'
local Item = require 'items/item'
local SwordItem = {}
SwordItem.__index = SwordItem
SwordItem.isSwordItem = true

local SwordItemImage = love.graphics.newImage('images/sword_item.png')
local Sword = require 'nodes/sword'

local GS = require 'vendor/gamestate'

---
-- Creates a new Sword item object
-- @return the Sword item object created
function SwordItem.new()
   local swordItem = {}
   setmetatable(swordItem, SwordItem)
   swordItem = inherits(swordItem,Item)
   swordItem.image = SwordItemImage
   swordItem.type = 'Weapon'
   swordItem.quantity = 1
   swordItem.isHolding = false
   swordItem.nodeType = "sword"
   swordItem.parentNode = Sword

   return swordItem
end

return SwordItem
