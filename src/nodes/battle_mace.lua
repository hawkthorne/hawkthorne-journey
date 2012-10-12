-----------------------------------------------
-- battle_mace.lua
-- Represents a mace that a player has thrown
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'

local Mace = {}
Mace.__index = Mace
Mace.mace = true

local MaceImage = love.graphics.newImage('images/mace.png')
local MaceWieldingImage = love.graphics.newImage('images/mace_wielding.png')

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Mace.new(node, collider, plyr)
    local mace = {}
    setmetatable(mace, Mace)
    if plyr then
        --mace.image = MaceWieldingImage
    else
        --mace.image = MaceImage
    end
    mace.foreground = node.properties.foreground
    mace.position = {x = node.x - 12, y = node.y}
    mace.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    mace.width = node.width
    mace.height = node.height

    --48x36  box
    mace.bb = collider:addRectangle(mace.position.x + 12, mace.position.y + 12, 
                                    mace.width, mace.height-12)
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
    mace.offsetX = 10
    mace.offsetY = -10
    mace.isWeapon = true

    return mace
end

---
-- Draws the mace to the screen
-- @return nil
function Mace:draw()
    if self.dead then return end
    local scalex = 1
    if ((self.velocity.x + 0)< 0) then
        scalex = -1
    end
    local animation = self:animation()
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y)
end

---
-- Called when the mace begins colliding with another node
-- @return nil
function Mace:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)
    end
end

---
-- Called when the mace finishes colliding with another node
-- @return nil
function Mace:collide_end(node, dt)
end

---
-- Updates the mace and moves it around.
function Mace:update(dt)
    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:animation()
    animation:update(dt)
    
--    self.player:animation():update(dt)

    if animation.status == "finished" then
        --print("animation complete"..self.player.direction)
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
    end

    local playerCenterX = self.player.position.x+self.player.width/2
    local playerCenterY = self.player.position.y+self.player.height/2

    local maceHeight = self.height
    local maceWidth = self.width
    local maceX = playerCenterX - maceWidth/2  --subtracts half of the frame width
    local maceY = playerCenterY - maceHeight/2

    --self.position = {x=maceX + playerDirection*self.offsetX,
    --                 y=maceY + self.offsetY}
    self.position = {x=self.player.position.x + playerDirection*12,
                     y=self.player.position.y}
    if self.player.direction == "left" then
        self.bb:moveTo(self.position.x + 25, self.position.y+12)
    else
        self.bb:moveTo(self.position.x + 30, self.position.y+12)
    end
end

function Mace:wield()
    print("wielding")
    self.collider:setActive(self.bb)

    self.player.state = 'wieldaction'

    if not self.wielding then
        local h = anim8.newGrid(48, 48, 192, 96)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        if self.player.direction == 'right' then
            self.animations['right'] = anim8.newAnimation('once', h('1-4,1'), self.wield_rate)
            self.player.animations['wieldaction']['right'] = anim8.newAnimation('once', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else 
            self.animations['left'] = anim8.newAnimation('once', h('1-4,2'), self.wield_rate)
            self.player.animations['wieldaction']['left'] = anim8.newAnimation('once', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
end

---
-- Called when the knife begins colliding with another node
-- @return nil
function Mace:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)

        self.collider:setPassive(self.bb)
        self.wielding = false
    end
end


function Mace:animation()
    return self.animations[self.player.direction]
end


return Mace