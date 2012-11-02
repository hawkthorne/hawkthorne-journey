-----------------------------------------------
-- torchItem.lua
-- The code for the torch, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local Global = require 'global'
local Item = require 'items/item'
local TorchItem = {}
TorchItem.__index = TorchItem
TorchItem.isTorchItem = true

local TorchItemImage = love.graphics.newImage('images/torch_item.png')
local Torch = require 'nodes/torch'

local GS = require 'vendor/gamestate'

---
-- Creates a new Torch item object
-- @return the Torch item object created
function TorchItem.new()
   local torchItem = {}
   setmetatable(torchItem, TorchItem)
   torchItem = Global.inherits(torchItem,Item)
   torchItem.image = TorchItemImage
   torchItem.type = 'Weapon'
   torchItem.quantity = 1
   torchItem.isHolding = false
   torchItem.nodeType = "torch"
   torchItem.parentNode = Torch

   return torchItem
end

return TorchItem
