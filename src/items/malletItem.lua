-----------------------------------------------
-- malletItem.lua
-- The code for the mallet, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------

local MalletItem = {}
MalletItem.__index = MalletItem
MalletItem.malletItem = true

local MalletItemImage = love.graphics.newImage('images/mallet_item.png')
local Mallet = require 'nodes/mallet'

local GS = require 'vendor/gamestate'
MAX_MACES = 1
---
-- Creates a new Mallet item object
-- @return the Mallet item object created
function MalletItem.new()
   local malletItem = {}
   setmetatable(malletItem, MalletItem)
   malletItem.image = MalletItemImage
   malletItem.type = 'Weapon'
   malletItem.quantity = 1
   malletItem.deleteFlag = false
   malletItem.isHolding = false
   return malletItem
end

---
-- Draws the Mallet in the inventory
-- @return nil
function MalletItem:draw(position)
   love.graphics.drawq(self.image, love.graphics.newQuad(0,0, 15,15,15,15), position.x, position.y)
   love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
end

--takes out the mallet
function MalletItem:use(player)
    if self.quantity <= 1 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
    end
    self.quantity = self.quantity - 1

    local playerCenterX = player.position.x+player.width/2
    local playerCenterY = player.position.y+player.height/2

    local playerDirection = 1
    if player.direction == "left" then playerDirection = -1 end
    local malletHeight = 24
    local malletWidth = 24
    local malletX = playerCenterX - malletWidth/2
    local malletY = playerCenterY - malletHeight/2
    local malletOffsetX = 15
    local malletOffsetY = 10

    local malletNode = { 
                        name = "",
                        x = player.position.x,
                        y = player.position.y,
                        width = 20,
                        height = 30,
                        type = "mallet",
                        properties = {
                          ["velocityX"] = (0) .. "",
                          ["velocityY"] = "0",
                          ["foreground"] = "false",
                        },
                       }
    
    local mallet = Mallet.singleton
    if not mallet then
        mallet = Mallet.new(malletNode, GS.currentState().collider,player,self)
    end
    player.currently_held = mallet
    table.insert(GS.currentState().nodes, mallet)
end

return MalletItem
