-----------------------------------------------
-- torchItem.lua
-- The code for the torch, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local sound = require 'vendor/TEsound'

local TorchItem = {}
TorchItem.__index = TorchItem
TorchItem.torchItem = true

local TorchItemImage = love.graphics.newImage('images/torch_item.png')
local Torch = require 'nodes/torch'

local GS = require 'vendor/gamestate'
MAX_SWORDS = 1
---
-- Creates a new Torch item object
-- @return the Torch item object created
function TorchItem.new()
   local torchItem = {}
   setmetatable(torchItem, TorchItem)
   torchItem.image = TorchItemImage
   torchItem.type = 'Weapon'
   torchItem.quantity = 1
   torchItem.deleteFlag = false
   torchItem.isHolding = false
   return torchItem
end

---
-- Draws the Torch in the inventory
-- @return nil
function TorchItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end

--takes out the torch
function TorchItem:use(player)
    if self.quantity <= 1 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
    end
    self.quantity = self.quantity - 1

    local torchNode = { 
                        name = "", 
                        x = player.position.x,
                        y = player.position.y,
                        width = 24,
                        height = 48, --location of the bottom of the torch
                                     --doesn't matter how large the image is, just the visual torch
                        type = "torch",
                        properties = {
                          ["velocityX"] = (0) .. "",
                          ["velocityY"] = "0",
                          ["foreground"] = "true",
                        },
                       }
    local torch = Torch.singleton
    if not torch then
        torch = Torch.new(torchNode, GS.currentState().collider,player,self)
    end
    player.currently_held = torch
    table.insert(GS.currentState().nodes, torch)
    sound.playSfx( "fire" )
end

return TorchItem
