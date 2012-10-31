-----------------------------------------------
-- malletItem.lua
-- The code for the mallet, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local Global = require 'global'
local Item = require 'items/item'
local MalletItem = {}
MalletItem.__index = MalletItem
MalletItem.malletItem = true

local MalletItemImage = love.graphics.newImage('images/mallet_item.png')
local Mallet = require 'nodes/mallet'

local GS = require 'vendor/gamestate'

---
-- Creates a new Mallet item object
-- @return the Mallet item object created
function MalletItem.new()
   local malletItem = {}
   setmetatable(malletItem, MalletItem)
   malletItem = Global.inherits(malletItem,Item)
   malletItem.image = MalletItemImage
   malletItem.type = 'Weapon'
   malletItem.quantity = 1
   malletItem.isHolding = false
   malletItem.nodeType = "mallet"
   malletItem.parentNode = Mallet

   return malletItem
end

return MalletItem
