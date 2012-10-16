local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local coin = require 'nodes/coin'

local Acorn = {}
Acorn.__index = Acorn

local sprite = love.graphics.newImage('images/acorn.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(20, 20, sprite:getWidth(), sprite:getHeight())

function Acorn.new(node, collider)
    local acorn = {}
    setmetatable(acorn, Acorn)
    
    acorn.node = node
    acorn.collider = collider
    acorn.node = node
    acorn.dead = false
    acorn.width = 20
    acorn.height = 20
    acorn.damage = 1

    acorn.position = {x=node.x, y=node.y+4}
    acorn.velocity = {x=0, y=0}
    acorn.state = 'walk'      -- default animation is idle
    acorn.direction = 'left'   -- default animation faces right direction is right
    acorn.animations = {
        dying = {
            right = anim8.newAnimation('once', g('1-2,1'), 0.25),
            left = anim8.newAnimation('once', g('1-2,2'), 0.25)
        },
        walk = {
            right = anim8.newAnimation('loop', g('3-5,1'), 0.25),
            left = anim8.newAnimation('loop', g('3-5,2'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('8-10,1'), 0.25),
            left = anim8.newAnimation('loop', g('8-10,2'), 0.25)
        }
    }

    acorn.bb = collider:addRectangle(node.x, node.y,24,24)
    acorn.bb.node = acorn
    collider:setPassive(acorn.bb)
    
    acorn.coins = {}

    return acorn
end

function Acorn:animation()
    return self.animations[self.state][self.direction]
end

function Acorn:hit()
    self.state = 'attack'
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'walk' end
    end)
end

function Acorn:die()
    sound.playSfx( "hippie_kill" )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(1, function() self.dead = true end)
    self.coins = {
        coin.new(self.position.x + self.width / 2, self.position.y + self.height, self.collider, 1),
    }
end

function Acorn:collide(player, dt, mtv_x, mtv_y)
    if player.rebounding then
        return
    end

    local a = player.position.x < self.position.x and -1 or 1
    local x1,y1,x2,y2 = self.bb:bbox()

    if player.position.y + player.height <= y2 and player.velocity.y > 0 then 
        -- successful attack
        self:die()
        if cheat.jump_high then
            player.velocity.y = -670
        else
            player.velocity.y = -450
        end
        return
    end

    if cheat.god then
        self:die()
        return
    end
    
    if player.invulnerable then
        return
    end
    
    self:hit()

    player:die(self.damage)
    player.bb:move(mtv_x, mtv_y)
    player.velocity.y = -450
    player.velocity.x = 300 * a
end


function Acorn:update(dt, player)
    for _,c in pairs(self.coins) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' then
        return
    end


    if self.position.x > player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if math.abs(self.position.x - player.position.x) < 2 then
        -- stay put
    elseif self.direction == 'left' then
        self.position.x = self.position.x - (10 * dt)
    else
        self.position.x = self.position.x + (10 * dt)
    end

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2 + 10)
end

function Acorn:draw()
    if not self.dead then
        self:animation():draw( sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end

    for _,c in pairs(self.coins) do
        c:draw()
    end
end

return Acorn
