local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'

local Mannequin = {}
Mannequin.__index = Mannequin

local sprite = love.graphics.newImage('images/mannequin.png')
sprite:setFilter('nearest', 'nearest')

local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

function Mannequin.new(node, collider)
    local mannequin = {}

    setmetatable(mannequin, Mannequin)
    mannequin.collider = collider
    mannequin.dead = false
    mannequin.width = 48
    mannequin.height = 48
    mannequin.damage = 1
    mannequin.position = {x=node.x, y=node.y}
    mannequin.velocity = {x=0, y=0}
    mannequin.state = 'wait'    -- default animation 
    mannequin.direction = 'left'   -- default direction 
    mannequin.animations = {
        wait = {
            right = anim8.newAnimation('loop', g('1,2'), 0.25),
            left = anim8.newAnimation('loop', g('1,1'), 0.25)
        },
        crawl = {
            right = anim8.newAnimation('loop', g('1-3,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-3,1'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('4-5,2'), 0.25),
            left = anim8.newAnimation('loop', g('4-5,1'), 0.25)
        },
        dying = {
            right = anim8.newAnimation('once', g('6,1'), 1),
            left = anim8.newAnimation('once', g('6,1'), 1)
        }
    }
    mannequin.bb = collider:addRectangle(node.x,node.y,30,25)
    mannequin.bb.node = mannequin
    collider:setPassive(mannequin.bb)
    return mannequin
end

function Mannequin:animation()
    return self.animations[self.state][self.direction]
end

function Mannequin:hit()
    self.state = 'attack'
    Timer.add(1, function() 
        if self.state ~= 'dying' then self.state = 'crawl' end
    end)
end

function Mannequin:die()
    sound.playSfx( "mannequin_death" )
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
end

function Mannequin:collide(player, dt, mtv_x, mtv_y)
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


function Mannequin:update(dt, player)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
        return
    end

    if math.abs(self.position.y - player.position.y) < 3 and math.abs(self.position.x - player.position.x) < 82 and self.position.x > player.position.x then
        -- if on same y axis, within set distance, and player on left     
    self.state = 'crawl'
        self.direction = 'left'
    elseif math.abs(self.position.y - player.position.y) < 3 and math.abs(self.position.x - player.position.x) < 82 and self.position.x < player.position.x then
        -- if on same y axis, within set distance, and player on right     
        self.state = 'crawl' 
        self.direction = 'right'
    else  
    -- if neither continue to wait
        self.state = 'wait'
    end

    if math.abs(self.position.x - player.position.x) < 2 then
        -- stay put if very close to player
    elseif self.direction == 'left' and self.state == 'crawl' then
        -- move to the left 
        self.position.x = self.position.x - (28 * dt)
    elseif self.direction == 'right' and self.state == 'crawl' then
        -- move to the right
        self.position.x = self.position.x + (28 * dt)
    else 
        -- otherwise stay still
    end

    self.bb:moveTo(self.position.x + self.width / 2,
    self.position.y + self.height / 2 + 10)
end

function Mannequin:draw()
    if self.dead then
        return
    end

    self:animation():draw(sprite, math.floor(self.position.x),
    math.floor(self.position.y))
end

return Mannequin
