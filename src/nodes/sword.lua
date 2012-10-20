-----------------------------------------------
-- battle_sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Sword = {}
Sword.__index = Sword
Sword.sword = true

--
-- Creates a new battle sword object
-- @return the battle sword object created
function Sword.new(node, collider, plyr, swordItem)
    local sword = {}
    setmetatable(sword, Sword)

    --subclass Weapon methods
    sword = Global.inherits(sword,Weapon)
    
    --populate data from the swordItem
    sword.item = swordItem
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

    --play the sheet
    sword:defaultAnimation()
    sword.wielding = false
    sword.action = 'wieldaction2'
    

    --create the bounding box
    local boxTopLeft = {x = sword.position.x,
                        y = sword.position.y}
    local boxWidth = sword.width
    local boxHeight = sword.height

    --sword.bb_radius = 30;
    --sword.bb_cx_offset= 0;
    --sword.bb_cy_offset = 24;

    --sword.bb = collider:addCircle(sword.position.x + sword.bb_cx_offset, sword.position.y + sword.bb_cy_offset, sword.bb_radius)

    --update the collider using the bounding box
    sword.bb = collider:addRectangle(boxTopLeft.x,boxTopLeft.y,boxWidth,boxHeight)
    sword.bb.node = sword
    sword.collider = collider
    sword.collider:setPassive(sword.bb)

    sword.damage = 4
    sword.dead = false
    sword.player = plyr

    sword.wield_rate = 0.09
    
    --set audioclips played by Weapon
    --audio clip when weapon is put away
    sword.unuseAudioClip = 'sword_sheathed'
    
    --audio clip when weapon hits something
    sword.hitAudioClip = 'sword_hit'

    --temporary until persistence. limits sword creation
    sword.singleton = sword

    return sword
end

function Sword:wield()
    --if self.bb._center.x - self.bb._radius <= -math.huge then return
    --elseif self.bb._center.x + self.bb._radius >= math.huge then return end

    self.dead = false
    self.collider:setActive(self.bb)

    self.player:setSpriteStates('wielding')

    if not self.wielding then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1'), self.wield_rate)
        if self.player.direction == 'right' then
            self.player.animations[self.action]['right'] = anim8.newAnimation('loop', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else
            self.player.animations[self.action]['left'] = anim8.newAnimation('loop', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end

    end
    self.player.wielding = true
    self.wielding = true
    sound.playSfx( "sword_air" )

end

--creates excessive animations. fix this later
function Sword:defaultAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h(1,1), 1)
end

return Sword