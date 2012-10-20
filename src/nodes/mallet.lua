-----------------------------------------------
-- battle_mallet.lua
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
    mallet = Global.inherits(mallet,Weapon)

    mallet.item = malletItem
    mallet.foreground = node.properties.foreground
    mallet.position = {x = node.x, y = node.y}
    mallet.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    mallet.width = node.width
    mallet.height = node.height

    --can be local
    mallet.bb_radius = 10;
    mallet.bb_cx_offset= 0;
    mallet.bb_cy_offset = 24;

    mallet.bb = collider:addCircle(mallet.position.x + mallet.bb_cx_offset, mallet.position.y + mallet.bb_cy_offset, mallet.bb_radius)
    mallet.bb.node = mallet
    mallet.collider = collider
    mallet.collider:setPassive(mallet.bb)

    mallet.damage = 4
    mallet.dead = false
    mallet.player = plyr

    mallet.wield_rate = 0.09

    local rowAmt = 1
    local colAmt = 3
    mallet.frameWidth = 20
    mallet.frameHeight = 30
    mallet.sheetWidth = mallet.frameWidth*colAmt
    mallet.sheetHeight = mallet.frameHeight*rowAmt
    mallet:defaultAnimation()
    mallet.sheet = love.graphics.newImage('images/mallet_action.png')
    mallet.wielding = false
    mallet.isWeapon = true
    mallet.action = 'wieldaction'
    mallet.hand_x = 5
    mallet.hand_y = 16
    mallet.singleton = mallet

    return mallet
end


function Mallet:wield()
    self.dead = false
    self.collider:setActive(self.bb)

    self.player:setSpriteStates('wielding')

    if not self.wielding then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        self.animation = anim8.newAnimation('once', h('1,1','2,1','3,1','2,1'), self.wield_rate)
        if self.player.direction == 'right' then
            self.player.animations[self.action]['right'] = anim8.newAnimation('loop', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else
            self.player.animations[self.action]['left'] = anim8.newAnimation('loop', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
    sound.playSfx( "mallet_hit" )
end

function Mallet:defaultAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('once', h(1,1), 1)
end

return Mallet