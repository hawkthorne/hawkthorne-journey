-----------------------------------------------
-- battle_mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/genericWeapon'

local Mace = {}
Mace.__index = Mace
Mace.mace = true

local MaceImage = love.graphics.newImage('images/mace.png')

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Mace.new(node, collider, plyr, maceItem)
    local mace = {}
    setmetatable(mace, Mace)
    mace = Weapon.addWeaponMethods(mace)

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

    local h = anim8.newGrid(48, 48, 192, 96)
    mace.animations = {
            right = anim8.newAnimation('once', h('1,1'), 1),
            left = anim8.newAnimation('once', h('1,2'), 1)
        }
    mace.sheet = love.graphics.newImage('images/mace_action3.png')
    mace.wielding = false
    mace.isWeapon = true
    mace.action = 'wieldaction'

    return mace
end

---
-- Updates the mace and moves it around.
function Mace:update(dt)
    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:animation()
    animation:update(dt)

    local player = self.player
    if self.player.direction == "right" then
        self.position.x = math.floor(player.position.x) + player.offset_hand_left[1]
        self.position.y = math.floor(player.position.y) + player.offset_hand_left[2]-26
    else
        self.position.x = math.floor(player.position.x) + player.offset_hand_right[1]
        self.position.y = math.floor(player.position.y) + player.offset_hand_right[2]-26
    end
    --self.position.x = self.position.x - 38
    --self.position.y = self.position.y + 20
    if player.offset_hand_right[1] == 0 then
        print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
    end
    --self:moveBoundingBox()

    
    --self.position = {x=self.player.position.x + playerDirection*12,
    --                 y=self.player.position.y}

    if animation.position == 1 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 22, self.position.y+11)
        else
            self.bb:moveTo(self.position.x + (48-22), self.position.y+11)
        end
    elseif animation.position == 2 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 37, self.position.y+23)
        else
            self.bb:moveTo(self.position.x + (48-37), self.position.y+23)
        end
    elseif animation.position == 3 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 35, self.position.y+37)
        else
            self.bb:moveTo(self.position.x + (48-35), self.position.y+37)
        end
    elseif animation.position == 4 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 23, self.position.y+9)
        else
            self.bb:moveTo(self.position.x + (48-23), self.position.y+9)
        end
    end

    if animation.status == "finished" then
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
    end

end

function Mace:wield()
    self.dead = false
    self.collider:setActive(self.bb)

    self.player:setSpriteStates('wielding')

    if not self.wielding then
        local h = anim8.newGrid(48, 48, 192, 96)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        if self.player.direction == 'right' then
            self.animations['right'] = anim8.newAnimation('once', h('1-4,1'), self.wield_rate)
            self.player.animations[self.action['right'] = anim8.newAnimation('once', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else 
            self.animations['left'] = anim8.newAnimation('once', h('1-4,2'), self.wield_rate)
            self.player.animations[self.action]['left'] = anim8.newAnimation('once', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
end

return Mace