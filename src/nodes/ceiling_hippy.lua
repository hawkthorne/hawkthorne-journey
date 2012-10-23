local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local splat = require 'nodes/splat'
local coin = require 'nodes/coin'
local Enemy = require 'nodes/enemy'

local Hippie = {}
Hippie.__index = Hippie

local sprite = love.graphics.newImage('images/hippy.png')
sprite:setFilter('nearest', 'nearest')
local g = anim8.newGrid(48, 48, sprite:getWidth(), sprite:getHeight())

local open_ceiling = love.graphics.newImage('images/open_ceiling.png')
local broken_tiles = love.graphics.newImage('images/broken_tiles.png')

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
    hippie.dropped = false
    hippie.floor = node.y + node.height - 48
    hippie.dropspeed = 600

    hippie.position = {x=node.x + 24, y=node.y}
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

    hippie.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
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


function Hippie:collide(player, dt, mtv_x, mtv_y)
    if not self.dropped then
        -- //change the bounding box
        sound.playSfx('hippy_enter')
        self.collider:remove(self.bb)
        self.bb = self.collider:addRectangle(self.node.x, self.node.y,30,25)
        self.bb.node = self
        self.collider:setPassive(self.bb)
        self.dropped = true
        return
    end
    
    self.hippy:collide(player, dt, mtv_x, mtv_y)
end


function Hippie:update(dt, player)
    if not self.dropped then
        return
    end
    if self.dropped and not self.hippy then
    	self.node.properties.name = "hippy"
		self.node.properties.floor = self.floor
    	self.hippy = Enemy.new(self.node, self.collider)
    	return
    end
    self.hippy:update(dt, player)
end

function Hippie:draw()
    if not self.dropped then
        return
    end
    love.graphics.draw( open_ceiling, self.node.x, self.node.y )
    love.graphics.draw( broken_tiles, self.node.x, self.node.y + self.node.height )
    
    self.hippy:draw()
end

return Hippie
