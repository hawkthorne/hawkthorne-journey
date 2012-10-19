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
    sword = Global.inherits(sword,Weapon)

    sword.item = swordItem
    sword.foreground = node.properties.foreground
    sword.position = {x = node.x, y = node.y}
    sword.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    sword.width = node.width
    sword.height = node.height

    --can be local
    sword.bb_radius = 30;
    sword.bb_cx_offset= 0;
    sword.bb_cy_offset = 24;

    sword.bb = collider:addCircle(sword.position.x + sword.bb_cx_offset, sword.position.y + sword.bb_cy_offset, sword.bb_radius)
    sword.bb.node = sword
    sword.collider = collider
    sword.collider:setPassive(sword.bb)

    sword.damage = 4
    sword.dead = false
    sword.player = plyr

    sword.wield_rate = 0.09

    local rowAmt = 1
    local colAmt = 3
    sword.frameWidth = 50
    sword.frameHeight = 40
    sword.sheetWidth = sword.frameWidth*colAmt
    sword.sheetHeight = sword.frameHeight*rowAmt
    sword:defaultAnimation()
    sword.sheet = love.graphics.newImage('images/sword_action.png')
    sword.wielding = false
    sword.isWeapon = true
    sword.action = 'wieldaction2'
    sword.hand_x = 24
    sword.hand_y = 30
    
    sword.unuseAudioClip = 'sword_sheathed'

    return sword
end

function Sword:wield()
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
    sound.playSfx( "sword_hit" )

end
function Sword:defaultAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h(1,1), 1)
end

return Sword