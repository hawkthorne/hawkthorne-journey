-----------------------------------------------
-- torch.lua
-- Represents a torch that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Torch = {}
Torch.__index = Torch
Torch.torch = true

--
-- Creates a new battle torch object
-- @return the battle torch object created
function Torch.new(node, collider, plyr, torchItem)
    local torch = {}
    setmetatable(torch, Torch)
    
    --populate data from the torchItem
    torch.item = torchItem
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
    torch.animation = torch:defaultAnimation()
    torch.wielding = false
    torch.action = 'wieldaction'

    --create the bounding box
    local boxTopLeft = {x = torch.position.x,
                        y = torch.position.y}
    local boxWidth = torch.width
    local boxHeight = torch.height

    --update the collider using the bounding box
    torch.bb = collider:addRectangle(boxTopLeft.x,boxTopLeft.y,boxWidth,boxHeight)
    torch.bb.node = torch
    torch.collider = collider
    torch.collider:setPassive(torch.bb)

    torch.damage = 4
    torch.dead = false
    torch.player = plyr

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --torch.unuseAudioClip = 'sword_sheathed'
    
    --audio clip when weapon hits something
    --torch.hitAudioClip = 

    --audio clip when weapon swing through air
    torch.swingAudioClip = 'fire_thrown'    

    --temporary until persistence. limits torch creation
    torch.singleton = torch

    --subclass Weapon methods and set defaults if not populated
    torch = Global.inherits(torch,Weapon)
    
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