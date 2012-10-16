-----------------------------------------------
-- battle_sword.lua
-- Represents a sword that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/genericWeapon'

local Sword = {}
Sword.__index = Sword
Sword.sword = true

local SwordImage = love.graphics.newImage('images/sword.png')

--
-- Creates a new battle sword object
-- @return the battle sword object created
function Sword.new(node, collider, plyr, swordItem)
    local sword = {}
    setmetatable(sword, Sword)
    sword = Weapon.addWeaponMethods(sword)

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

    local h = anim8.newGrid(48, 48, 192, 96)
    sword.animations = {
            right = anim8.newAnimation('once', h('1,1'), 1),
            left = anim8.newAnimation('once', h('1,2'), 1)
        }
    sword.sheet = love.graphics.newImage('images/sword_action.png')
    sword.wielding = false
    sword.isWeapon = true
    sword.action = 'wieldaction2'

    return sword
end

---
-- Updates the sword and moves it around.
function Sword:update(dt)
    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:animation()
    animation:update(dt)

    local player = self.player
    if self.player.direction == "right" then
        self.position.x = math.floor(player.position.x) + player.offset_hand_left[1]
        self.position.y = math.floor(player.position.y) + player.offset_hand_left[2]-34
    else
        self.position.x = math.floor(player.position.x) + player.offset_hand_right[1]
        self.position.y = math.floor(player.position.y) + player.offset_hand_right[2]-34
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

function Sword:wield()
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
            self.player.animations[self.action]['right'] = anim8.newAnimation('once', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else 
            self.animations['left'] = anim8.newAnimation('once', h('1-4,2'), self.wield_rate)
            self.player.animations[self.action]['left'] = anim8.newAnimation('once', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
end

return Sword