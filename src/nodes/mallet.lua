-----------------------------------------------
-- mallet.lua
-- Represents a mallet that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local Global = require 'global'
local GS = require 'vendor/gamestate'
local controls = require 'controls'


local Mallet = {}
Mallet.__index = Mallet
Mallet.isMallet = true

--
-- Creates a new battle mallet object
-- @return the battle mallet object created
function Mallet.new(node, collider, plyr, malletItem)
    local mallet = {}
    setmetatable(mallet, Mallet)
    mallet.name = "mallet"

    --subclass Weapon methods and set defaults if not populated
    mallet = Global.inherits(mallet,Weapon)

    --populate mallet.item... this indicates if the weaponed spawned from inventory
    mallet.item = malletItem

    --set the player if (s)he exists
    mallet:setPlayer(plyr)
    
    --set the node properties
    mallet.foreground = node.properties.foreground
    mallet.position = {x = node.x, y = node.y}
    mallet.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame
    mallet.hand_x = 5
    mallet.hand_y = 16

    --setting up the sheet
    local rowAmt = 1
    local colAmt = 3
    mallet.frameWidth = 20
    mallet.frameHeight = 30
    mallet.sheetWidth = mallet.frameWidth*colAmt
    mallet.sheetHeight = mallet.frameHeight*rowAmt
    mallet.width = mallet.frameWidth
    mallet.height = mallet.frameHeight
    mallet.sheet = love.graphics.newImage('images/mallet_action.png')

    mallet.wield_rate = 0.09

    --play the sheet
    mallet:initializeSheet()

    mallet.damage = 4
    mallet.dead = false

    --create the bounding box
    mallet:initializeBoundingBox(collider)

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --mallet.unuseAudioClip = 'sword_sheathed'

    --audio clip when weapon hits something
    mallet.hitAudioClip = 'mallet_hit'

    --audio clip when weapon swing through air
    --mallet.swingAudioClip = 'fire_thrown' 
    
    --local h = anim8.newGrid(mallet.frameWidth,mallet.frameHeight,mallet.sheetWidth,mallet.sheetHeight)
    --    local sheet = mallet.sheet
    --return SingleBomb.new(self,self.collider)

    -- local malletNode = {x=mallet.player.position.x, y=mallet.player.position.y,
                    -- width = 40, height = 30}
    -- malletNode.properties = {animationGrid = h,
                       -- defaultAnimation = mallet:defaultAnimation(),
                       -- endAnimation = mallet:wieldAnimation(),
                       -- sheet = sheet,
                       -- footLocation = mallet.player.position.y+mallet.player.height,
                       -- bounceFactor = 0.4,   --effect of floor on velocity y
                       ----                        -1 goes through a floor)
                       ----                        1 is perfectly elastic bounce                                             
                       -- objectFriction = 0.8, --effect of floor on velocity.x
                       -- velocityX = 500, velocityY=-50}
    -- local malletProj = Projectile.new(malletNode,mallet.collider,GS.currentState().map)
    -- print("hello")
    -- print(mallet.velocity.x)
    -- mallet = Global.inherits(mallet,malletProj)
    -- mallet.x = mallet.position.x
    -- mallet.y = mallet.position.y
    -- mallet.velocity = {x = malletNode.properties.velocityX,
                       -- y = malletNode.properties.velocityY,
                       -- }
    -- print(mallet.velocity.x)
    -- print("nurse")
    
    return mallet
end

function Mallet:defaultAnimation()
    if not self.defaultAnim then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        self.defaultAnim = anim8.newAnimation('once', h(1,1), self.wield_rate)
    end
    return self.defaultAnim
end


function Mallet:wieldAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1','2,1'), self.wield_rate)
end

return Mallet