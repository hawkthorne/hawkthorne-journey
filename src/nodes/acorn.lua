local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local Helper = require 'helper'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local game = require 'game'
local token = require 'nodes/token'
local droppable = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.95 },
    { item = 'health', v = 1, p = 1 }
}

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
    --collider:setPassive(acorn.bb)
    
    acorn.dropped = {}

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
    if self.state == 'fury' then
        sound.playSfx( "acorn_growl" )
        self.state = 'dyingfury'
    else
        sound.playSfx( "acorn_squeak" )
        self.state = 'dying'
    end
    sound.playSfx( "acorn_crush" )
    self.collider:setGhost(self.bb)
    Timer.add(1, function() self.dead = true end)
    self:dropitems(1)
end

function Acorn:dropitems( count )
    for i=1,count do
        local r = math.random(100) / 100
        for _,d in pairs( droppable ) do
            if r < d.p then
                table.insert(
                    self.dropped,
                    token.new(d.item,self.position.x + self.width / 2, self.position.y + self.height, self.collider, d.v)
                )
                break
            end
        end
    end
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


function Acorn:update(dt, player, level)
    local rage_velocity

    for _,c in pairs(self.dropped) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'dyingfury' then
        return
    end

    -- Gravity
    self.velocity.y = self.velocity.y + game.gravity * dt
    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
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
    self.position.y = self.position.y + (self.velocity.y * dt)

    if self.position.y > level.boundary.height
                         and self.state ~= 'dying'
                         and self.state ~= 'dyingfury' then
        self:die()
    end

    self:moveBoundingBox()
end

----- Platformer interface

function Acorn:wall_collide_floor(node, new_y)
    self.position.y = new_y
    self.velocity.y = 0
    self:moveBoundingBox()
end

function Acorn:wall_collide_side(node, new_x)
    self.position.x = new_x
    self.velocity.x = 0
    self:moveBoundingBox()
end

function Acorn:moveBoundingBox()
    Helper.moveBoundingBox(self)
end

function Acorn:draw()
    if not self.dead then
        self:animation():draw( sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end

    for _,c in pairs(self.dropped) do
        c:draw()
    end
end

return Acorn
