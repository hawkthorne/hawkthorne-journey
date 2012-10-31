-----------------------------------------------
-- bombsItem.lua
-- The code for the bombs, when it in the players inventory.
-- Created by NimbusBP1729
-----------------------------------------------
local Global = require 'global'
local Item = require 'items/item'

local BombsItem = {}
BombsItem.__index = BombsItem
BombsItem.bombsItem = true

local BombsItemImage = love.graphics.newImage('images/bombs_item.png')
local Bombs = require 'nodes/bombs'

---
-- Creates a new Bombs item object
-- @return the Bombs item object created
function BombsItem.new()
   local bombsItem = {}
   setmetatable(bombsItem, BombsItem)
   bombsItem = Global.inherits(bombsItem,Item)
   bombsItem.image = BombsItemImage
   bombsItem.type = 'Weapon'
   bombsItem.quantity = 5
   bombsItem.nodeType = "bombs"
   bombsItem.parentNode = Bombs
   return bombsItem
end


return BombsItem
