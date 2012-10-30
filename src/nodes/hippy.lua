local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local splat = require 'nodes/splat'
local coin = require 'nodes/coin'

local Hippie = {}
Hippie.__index = Hippie

local sprite = love.graphics.newImage('images/hippy.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

function Hippie.new(node, collider)
    local hippie = {}
    setmetatable(hippie, Hippie)
    
    hippie.node = node
    hippie.collider = collider
    hippie.node = node
    hippie.dead = false
    hippie.width = 48
    hippie.height = 48
    hippie.damage = 1

    hippie.position = {x=node.x, y=node.y}
    hippie.velocity = {x=0, y=0}
    hippie.state = 'crawl'      -- default animation is idle
    hippie.direction = 'left'   -- default animation faces right direction is right
    hippie.animations = {
        dying = {
            right = anim8.newAnimation('once', g('5,2'), 1),
            left = anim8.newAnimation('once', g('5,1'), 1)
        },
        crawl = {
            right = anim8.newAnimation('loop', g('3-4,2'), 0.25),
            left = anim8.newAnimation('loop', g('3-4,1'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        }
    }

    hippie.bb = collider:addRectangle(node.x, node.y,30,25)
    hippie.bb.node = hippie
    collider:setPassive(hippie.bb)
    
    hippie.coins = {}

    return hippie
end

function Hippie:animation()
    return self.animations[self.state][self.direction]
end

function Hippie:hit()
    self.state = 'attack'
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'crawl' end
    end)
end

function Hippie:die()
    sound.playSfx( "hippie_kill" )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
    self.splat = splat:add(self.position.x, self.position.y, self.width, self.height)
    self.coins = {
        coin.new(self.position.x + self.width / 2, self.position.y + self.height, self.collider, 1),
        coin.new(self.position.x + self.width / 2, self.position.y + self.height, self.collider, 1),
        coin.new(self.position.x + self.width / 2, self.position.y + self.height, self.collider, 1),
    }
end

function Hippie:collide(player, dt, mtv_x, mtv_y)
    if not player.isPlayer then return
    if not player.current_hippie then
        player.current_hippie = self
    end
    
    if player.current_hippie == self then
        
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
end

function Hippie:collide_end( player )
    if player.current_hippie == self then
        player.current_hippie = nil
    end
end

function Hippie:update(dt, player)
    for _,c in pairs(self.coins) do
        c:update(dt)
    end
    
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
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

function Hippie:draw()
    if not self.dead then
        self:animation():draw( sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end

    for _,c in pairs(self.coins) do
        c:draw()
    end
end

return Hippie
