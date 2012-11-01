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
    acorn.maxx = node.x + 24
    acorn.minx = node.x - 24
    acorn.state = 'walk'      -- default animation is idle
    local directions = {'left','right'}
    acorn.direction = directions[math.random(#directions)] -- default animation faces right direction is right
    acorn.onfloor = true
    acorn.animations = {
        dying = {
            right = anim8.newAnimation('once', g('1,1'), 0.25),
            left = anim8.newAnimation('once', g('1,2'), 0.25)
        },
        walk = {
            right = anim8.newAnimation('loop', g('3-4,1'), 0.25),
            left = anim8.newAnimation('loop', g('3-4,2'), 0.25)
        },
        fury = {
            right = anim8.newAnimation('loop', g('8-10,1'), 0.25),
            left = anim8.newAnimation('loop', g('8-10,2'), 0.25)
        },
        dyingfury = {
            right = anim8.newAnimation('once', g('2,1'), 0.25),
            left = anim8.newAnimation('once', g('2,2'), 0.25)
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
    self.state = 'fury'
    Timer.add(5, function() 
        if self.state ~= 'dying' and self.state ~= 'dyingfury' then self.state = 'walk' end
    end)
end

function Acorn:die()
    sound.playSfx( "hippie_kill" ) -- needs acorn death sound
    if self.state == 'fury' then
        self.state = 'dyingfury'
    else
        self.state = 'dying'
    end
    self.collider:setGhost(self.bb)
    Timer.add(1, function() self.dead = true end)
    self.coins = {
        coin.new(self.position.x + self.width / 2, self.position.y + self.height, self.collider, 1),
    }
end

function Acorn:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        local player = node
        if player.rebounding then
            return
        end

        local a = player.position.x < self.position.x and -1 or 1
        local x1,y1,x2,y2 = self.bb:bbox()

        if player.position.y + player.height <= (y2-5) and player.velocity.y > 0 and self.state ~= 'fury' then 
            -- successful attack
            self:die()
            if cheat.jump_high then
                player.velocity.y = -570
            else
                player.velocity.y = -350
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
end


function Acorn:update(dt, player)
    local rage_velocity

    for _,c in pairs(self.coins) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'dyingfury' then
        return
    end

    if self.state == 'fury' then
        rage_velocity = 4
     else
        rage_velocity = 1
        max = 1
     end
     
    if self.state == 'fury' then
        if self.position.x > player.position.x then
            self.direction = 'left'
        else
            self.direction = 'right'
        end
        
    else
        if self.position.x > self.maxx then
            self.direction = 'left'
        elseif self.position.x < self.minx then
            self.direction = 'right'
        end
    end
    if math.abs(self.position.x - player.position.x) < 2 then
        -- stay put
    elseif self.direction == 'left'then
        self.velocity.x = 20 * rage_velocity
    else
        self.velocity.x = -20 * rage_velocity
    end
    self.position.x = self.position.x - (self.velocity.x * dt)

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2)
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
