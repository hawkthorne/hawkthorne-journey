-----------------------------------------------
-- battle_sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local Sword = {}
Sword.__index = Sword
Sword.isSword = true

--
-- Creates a new battle sword object
-- @return the battle sword object created
function Sword.new(node, collider, plyr, swordItem)
    local sword = {}
    setmetatable(sword, Sword)
    sword.name = "sword"

    --subclass Weapon methods and set defaults if not populated
    sword = inherits(sword,Weapon)
    
    --populate data from the swordItem
    sword.item = swordItem

    --set the player if (s)he exists
    sword:setPlayer(plyr)
    
    --set the node properties
    sword.foreground = node.properties.foreground
    sword.position = {x = node.x, y = node.y}
    sword.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame
    sword.hand_x = 24
    sword.hand_y = 30

    --setting up the sheet
    local rowAmt = 1
    local colAmt = 3
    sword.frameWidth = 50
    sword.frameHeight = 40
    sword.sheetWidth = sword.frameWidth*colAmt
    sword.sheetHeight = sword.frameHeight*rowAmt
    sword.width = sword.frameWidth
    sword.height = sword.frameHeight
    sword.sheet = love.graphics.newImage('images/sword_action.png')

    sword.wield_rate = 0.09

    --play the sheet
    sword:initializeSheet()
 
    sword.damage = 4
    sword.dead = false

    --create the bounding box
    sword:initializeBoundingBox(collider)

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    sword.unuseAudioClip = 'sword_sheathed'

    --audio clip when weapon hits something
    sword.hitAudioClip = 'sword_hit'

    --audio clip when weapon swing through air
    sword.swingAudioClip = 'sword_air'

    return sword
end

--creates excessive animations. fix this later
function Sword:defaultAnimation()
    if not self.defaultAnim then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        self.defaultAnim = anim8.newAnimation('once', h(1,1), 1)
    end
    return self.defaultAnim
end

function Sword:wieldAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1'), self.wield_rate)
end

return Sword