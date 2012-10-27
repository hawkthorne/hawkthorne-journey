local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local window = require 'window'
local sound = require 'vendor/TEsound'

local Pot = {}
Pot.__index = Pot

local potImage = love.graphics.newImage('images/pot.png')
local potExplode= love.graphics.newImage('images/pot_asplode.png')
local g = anim8.newGrid(41, 30, potExplode:getWidth(), potExplode:getHeight())


function Pot.new(node, collider)
    local pot = {}
    setmetatable(pot, Pot)
    pot.image = potImage
    pot.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    pot.bb.node = pot
    pot.collider = collider
    pot.collider:setPassive(pot.bb)
    pot.explode = anim8.newAnimation('once', g('1-5,1'), .10)

    pot.position = { x = node.x, y = node.y }
    pot.velocity = { x = 0, y = 0 }

    pot.floor = 0
    pot.die = false
    pot.thrown = false
    pot.held = false

    pot.width = node.width
    pot.height = node.height

    return pot
end

function Pot:draw()
    if self.die then
        self.explode:draw(potExplode, self.position.x, self.position.y)
    else
        love.graphics.draw(self.image, self.position.x, self.position.y)
    end
end

function Pot:collide(player, dt, mtv_x, mtv_y)
    player:registerHoldable(self)
end

function Pot:collide_end(player, dt)
    player:cancelHoldable(self)
end

function Pot:update(dt, player)
    if self.held then
        self.position.x = math.floor(player.position.x + (self.width / 2)) + 2
        self.position.y = math.floor(player.position.y + player.offset_hand_right[2] - self.height)
        self:moveBoundingBox()
        return
    end
    
    if self.die and self.explode.position ~= 5 then
        self.explode:update(dt)
        self.position.x = self.position.x + (self.velocity.x > 0 and 1 or -1) * 50 * dt
        return
    end

    if not (self.thrown or self.held) then
        return
    end

    self.velocity.y = self.velocity.y + 0.21875 * 10000 * dt

    if not self.held then
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
    end

    if self.position.x < 0 then
        self.velocity.x = -self.velocity.x
    end

    if self.position.x > window.width then
        self.velocity.x = -self.velocity.x
    end

    if self.thrown and self.position.y > self.floor then
        self.position.y = self.floor
        self.thrown = false
        self.die = true
        sound.playSfx('pot_break')
    end
end

function Pot:moveBoundingBox()
    Helper.moveBoundingBox(self)
end

function Pot:pickup(player)
    self.held = true
    self.velocity.y = 0
    self.velocity.x = 0
end

function Pot:throw(player)
    self.held = false
    self.thrown = true
    self.floor = player.position.y + player.height - self.height
    self.velocity.x = player.velocity.x + ((player.direction == "left") and -1 or 1) * 500
    self.velocity.y = player.velocity.y
    self.collider:setGhost(self.bb)
    player:cancelHoldable(self)
end

function Pot:throw_vertical(player)
    self.held = false
    self.thrown = true
    self.floor = player.position.y + player.height - self.height
    self.velocity.x = player.velocity.x
    self.velocity.y = player.velocity.y - 500
    self.collider:setGhost(self.bb)
    player:cancelHoldable(self)
end

function Pot:drop(player)
    self.held = false
    self.thrown = false
    self.position.y = player.position.y + player.height - self.height
    self.velocity.x = 0
    self.velocity.y = 0
    player:cancelHoldable(self)
end

return Pot

