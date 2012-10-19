-----------------------------------------------
-- battle_mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Mace = {}
Mace.__index = Mace
Mace.mace = true

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Mace.new(node, collider, plyr, maceItem)
    local mace = {}
    setmetatable(mace, Mace)
    mace = Global.inherits(mace,Weapon)

    mace.item = maceItem
    mace.foreground = node.properties.foreground
    mace.position = {x = node.x, y = node.y}
    mace.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    mace.width = node.width
    mace.height = node.height

    --can be local
    mace.bb_radius = 10;
    mace.bb_cx_offset= 0;
    mace.bb_cy_offset = 24;

    mace.bb = collider:addCircle(mace.position.x + mace.bb_cx_offset, mace.position.y + mace.bb_cy_offset, mace.bb_radius)
    mace.bb.node = mace
    mace.collider = collider
    mace.collider:setPassive(mace.bb)

    mace.damage = 4
    mace.dead = false
    mace.player = plyr

    mace.wield_rate = 0.09

    local rowAmt = 1
    local colAmt = 3
    mace.frameWidth = 50
    mace.frameHeight = 50
    mace.sheetWidth = mace.frameWidth*colAmt
    mace.sheetHeight = mace.frameHeight*rowAmt
    mace:defaultAnimation()
    mace.sheet = love.graphics.newImage('images/mace_action.png')
    mace.wielding = false
    mace.isWeapon = true
    mace.action = 'wieldaction'
    mace.hand_x = 9
    mace.hand_y = 40

    return mace
end


function Mace:wield()
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
    sound.playSfx( "mace_hit" )
end

function Mace:defaultAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h(1,1), 1)
end

return Mace