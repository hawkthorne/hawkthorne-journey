-----------------------------------------------
-- mallet.lua
-- Represents a mallet that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Mallet = {}
Mallet.__index = Mallet
Mallet.mallet = true

--
-- Creates a new battle mallet object
-- @return the battle mallet object created
function Mallet.new(node, collider, plyr, malletItem)
    local mallet = {}
    setmetatable(mallet, Mallet)
    
    --populate data from the malletItem
    mallet.item = malletItem
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
    mallet.animation = mallet:defaultAnimation()
    mallet.wielding = false
    mallet.action = 'wieldaction'

    --create the bounding box
    local boxTopLeft = {x = mallet.position.x,
                        y = mallet.position.y}
    local boxWidth = mallet.width
    local boxHeight = mallet.height

    --update the collider using the bounding box
    mallet.bb = collider:addRectangle(boxTopLeft.x,boxTopLeft.y,boxWidth,boxHeight)
    mallet.bb.node = mallet
    mallet.collider = collider
    mallet.collider:setPassive(mallet.bb)

    mallet.damage = 4
    mallet.dead = false
    mallet.player = plyr

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --mallet.unuseAudioClip = 'sword_sheathed'
    
    --audio clip when weapon hits something
    mallet.hitAudioClip = 'mallet_hit'

    --audio clip when weapon swing through air
    --mallet.swingAudioClip = 'fire_thrown'    

    --temporary until persistence. limits mallet creation
    mallet.singleton = mallet

    --subclass Weapon methods and set defaults if not populated
    mallet = Global.inherits(mallet,Weapon)
    
    return mallet
end

--creates excessive animations. fix this later
function Mallet:defaultAnimation()
    if not self.defaultAnim then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        self.defaultAnim = anim8.newAnimation('once', h(1,1), 1)
    end
    return self.defaultAnim
end

function Mallet:wieldAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
      self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1','2,1'), self.wield_rate)
end

return Mallet