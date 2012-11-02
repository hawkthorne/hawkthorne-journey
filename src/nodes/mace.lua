-----------------------------------------------
-- mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local utils = require 'utils'

local Mace = {}
Mace.__index = Mace
Mace.isMace = true

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Mace.new(node, collider, plyr, maceItem)
    local mace = {}
    setmetatable(mace, Mace)
    mace.name = "mace"

    --subclass Weapon methods and set defaults if not populated
    mace = inherits(mace,Weapon)

    --populate mace.item... this indicates if the weaponed spawned from inventory
    mace.item = maceItem

    --set the player if (s)he exists
    mace:setPlayer(plyr)
    
    --set the node properties
    mace.foreground = node.properties.foreground
    mace.position = {x = node.x, y = node.y}
    mace.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame
    mace.hand_x = 9
    mace.hand_y = 40

    --setting up the sheet
    local rowAmt = 1
    local colAmt = 3
    mace.frameWidth = 50
    mace.frameHeight = 50
    mace.sheetWidth = mace.frameWidth*colAmt
    mace.sheetHeight = mace.frameHeight*rowAmt
    mace.width = mace.frameWidth
    mace.height = mace.frameHeight
    mace.sheet = love.graphics.newImage('images/mace_action.png')

    mace.wield_rate = 0.09

    --play the sheet
    mace:initializeSheet()
 
    mace.damage = 4
    mace.dead = false

    --create the bounding box
    mace:initializeBoundingBox(collider)

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --mace.unuseAudioClip = 'sword_sheathed'
    
    --audio clip when weapon hits something
    mace.hitAudioClip = 'mace_hit'

    --audio clip when weapon swing through air
    --mace.swingAudioClip = 'fire_thrown'    

    return mace
end

--creates excessive animations. fix this later
function Mace:defaultAnimation()
    if not self.defaultAnim then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        self.defaultAnim = anim8.newAnimation('once', h(1,1), 1)
    end
    return self.defaultAnim
end

function Mace:wieldAnimation()
    local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
    self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1'), self.wield_rate)
end

return Mace