-----------------------------------------------
-- swordItem.lua
-- The code for the sword, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local sound = require 'vendor/TEsound'

local SwordItem = {}
SwordItem.__index = SwordItem
SwordItem.swordItem = true

local SwordItemImage = love.graphics.newImage('images/sword_item.png')
local Sword = require 'nodes/sword'

local GS = require 'vendor/gamestate'
MAX_SWORDS = 1
---
-- Creates a new Sword item object
-- @return the Sword item object created
function SwordItem.new()
   local swordItem = {}
   setmetatable(swordItem, SwordItem)
   swordItem.image = SwordItemImage
   swordItem.type = 'Weapon'
   swordItem.quantity = 1
   swordItem.deleteFlag = false
   swordItem.isHolding = false
   return swordItem
end

---
-- Draws the Sword in the inventory
-- @return nil
function SwordItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end

--takes out the sword
function SwordItem:use(player)
    if self.quantity <= 1 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
    end
    self.quantity = self.quantity - 1

    local swordNode = { 
                        name = "", 
                        x = player.position.x,
                        y = player.position.y,
                        width = 48,
                        height = 24, --location of the bottom of the sword
                                     --doesn't matter how large the image is, just the visual sword
                        type = "sword",
                        properties = {
                          ["velocityX"] = (0) .. "",
                          ["velocityY"] = "0",
                          ["foreground"] = "true",
                        },
                       }
    local sword = Sword.new(swordNode, GS.currentState().collider,player,self)
    player.currently_held = sword
    table.insert(GS.currentState().nodes, sword)
    sound.playSfx( "sword_unsheathed" )
end

return SwordItem
