-----------------------------------------------
-- torch.lua
-- Represents a torch that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local utils = require 'utils'

local Torch = {}
Torch.__index = Torch
Torch.isTorch = true

--
-- Creates a new battle torch object
-- @return the battle torch object created
function Torch.new(node, collider, plyr, torchItem)
    local torch = {}
    setmetatable(torch, Torch)
    torch.name = "torch"

    --subclass Weapon methods and set defaults if not populated
    torch = inherits(torch,Weapon)

    --populate torch.item... this indicates if the weaponed spawned from inventory
    torch.item = torchItem

    --set the player if (s)he exists
    torch:setPlayer(plyr)
    
    --set the node properties
    torch.foreground = node.properties.foreground
    torch.position = {x = node.x, y = node.y}
    torch.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame
    torch.hand_x = 1
    torch.hand_y = 41

    --setting up the sheet
    local rowAmt = 1
    local colAmt = 8
    torch.frameWidth = 24
    torch.frameHeight = 48
    torch.sheetWidth = torch.frameWidth*colAmt
    torch.sheetHeight = torch.frameHeight*rowAmt
    torch.width = 48--torch.frameWidth
    torch.height = torch.frameHeight
    torch.sheet = love.graphics.newImage('images/torch_action.png')

    torch.wield_rate = 0.09
    torch.burn_rate = 0.09

    --play the sheet
    torch:initializeSheet()
 
    torch.damage = 4
    torch.dead = false

    --create the bounding box
    torch:initializeBoundingBox(collider)

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --torch.unuseAudioClip = 'sword_sheathed'
    
    --audio clip when weapon hits something
    --torch.hitAudioClip = 

    --audio clip when weapon swing through air
    torch.swingAudioClip = 'fire_thrown'    

    return torch
end

--creates excessive animations. fix this later
function Torch:defaultAnimation()
    if not self.defaultAnim then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        self.defaultAnim = anim8.newAnimation('loop', h('1-6,1'), self.burn_rate)
    end
    return self.defaultAnim
end

function Torch:wieldAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h('7,1','8,1','7,1','8,1'), self.wield_rate)
end

return Torch