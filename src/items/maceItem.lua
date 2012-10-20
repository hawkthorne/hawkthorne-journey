-----------------------------------------------
-- maceItem.lua
-- The code for the mace, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------

local MaceItem = {}
MaceItem.__index = MaceItem
MaceItem.maceItem = true

local MaceItemImage = love.graphics.newImage('images/mace_item.png')
local Mace = require 'nodes/mace'

local GS = require 'vendor/gamestate'
MAX_MACES = 1
---
-- Creates a new Mace item object
-- @return the Mace item object created
function MaceItem.new()
   local maceItem = {}
   setmetatable(maceItem, MaceItem)
   maceItem.image = MaceItemImage
   maceItem.type = 'Weapon'
   maceItem.quantity = 1
   maceItem.deleteFlag = false
   maceItem.isHolding = false
   return maceItem
end

---
-- Draws the Mace in the inventory
-- @return nil
function MaceItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end

--takes out the mace
function MaceItem:use(player)
    if self.quantity <= 1 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
    end
    self.quantity = self.quantity - 1

    local playerCenterX = player.position.x+player.width/2
    local playerCenterY = player.position.y+player.height/2

    local playerDirection = 1
    if player.direction == "left" then playerDirection = -1 end
    local maceHeight = 24
    local maceWidth = 24
    local maceX = playerCenterX - maceWidth/2
    local maceY = playerCenterY - maceHeight/2
    local maceOffsetX = 15
    local maceOffsetY = 10

    local maceNode = { 
                        name = "",
                        x = player.position.x,
                        y = player.position.y,
                        width = 50,
                        height = 50,
                        type = "mace",
                        properties = {
                          ["velocityX"] = (0) .. "",
                          ["velocityY"] = "0",
                          ["foreground"] = "false",
                        },
                       }
    local mace = Mace.singleton
    if not mace then
        mace = Mace.new(maceNode, GS.currentState().collider,player,self)
    end
    player.currently_held = mace
    table.insert(GS.currentState().nodes, mace)
end

return MaceItem
