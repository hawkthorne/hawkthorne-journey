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
        mace.image = MaceWieldingImage
    else
        mace.image = MaceImage
    end
    mace.foreground = node.properties.foreground
    mace.bb = collider:addRectangle(node.x, node.y, node.width+5, node.height)
    mace.bb.node = mace
    mace.collider = collider
    mace.collider:setPassive(mace.bb)

    mace.position = {x = node.x, y = node.y}
    mace.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    mace.width = node.width
    mace.height = node.height
    mace.damage = 4
    mace.dead = false
    mace.player = plyr

    mace.wield_rate = 0.1

    local h = anim8.newGrid(48, 48, 192, 48)
    mace.animation = anim8.newAnimation('once', h('1-4,1'), mace.wield_rate)
    mace.sheet = love.graphics.newImage('images/mace_action2.png')
    mace.wielding = false

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

    self.animation:draw(self.sheet, math.floor(self.position.x), self.position.y)

    --love.graphics.drawq(self.image, love.graphics.newQuad(0, 0, self.width,self.height, self.width,self.height), self.position.x, self.position.y, 0, scalex, 1)
end

---
-- Called when the mace begins colliding with another node
-- @return nil
function Mace:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)
        self.dead = true
        self.collider:setGhost(self.bb)
    end
    if node.isSolid then
        self.dead = true
        self.collider:setGhost(self.bb)
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
    
    self.animation:update(dt)
    if self.animation.status == "finished" then
        self.collider:setPassive(self.bb)
        self.wielding = false
    end

    local playerCenterX = self.player.position.x+self.player.width/2
    local playerCenterY = self.player.position.y+self.player.height/2

    local maceHeight = self.height
    local maceWidth = self.width
    local maceX = playerCenterX - maceWidth/2
    local maceY = playerCenterY - maceHeight/2
    local maceOffset = 15

    self.position = {x=maceX + playerDirection*maceOffset,
                     y=maceY}
    self.bb:moveTo(self.position.x, self.position.y)
end

function Mace:wield()
    self.collider:setActive(self.bb)
    local h = anim8.newGrid(48, 48, 192, 48)

    self.animation = anim8.newAnimation('once', h('1-4,1'),self.wield_rate)
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
    end
end



return Mace