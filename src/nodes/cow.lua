local anim8 = require 'vendor/anim8'
local app = require 'app'

local Cow = {}
local Fly = {}

Cow.__index = Cow

local image = love.graphics.newImage('images/sprites/town/cow.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(114,60, image:getWidth(), image:getHeight())

local states = {
    left = anim8.newAnimation('once',g('1,1'), 1),
    right = anim8.newAnimation('once',g('2,1'), 1),
    up = anim8.newAnimation('once',g('3,1'), 1),
    up_left = anim8.newAnimation('once',g('1,2'), 1),
    up_right = anim8.newAnimation('once',g('2,2'), 1),
    straight = anim8.newAnimation('once',g('1,3'), 1),
    blink = anim8.newAnimation('once',g('2,3'), 1),
    dead = anim8.newAnimation('once',g('4,3'), 1),
}

function Fly.new(node, offset)
    local fly = {}
    setmetatable(fly, Fly)

    fly.sprite = love.graphics.newImage('images/sprites/town/fly.png')
    fly.sprite:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(5,5, fly.sprite:getWidth(), fly.sprite:getHeight())

    fly.animation = anim8.newAnimation('loop',g('1-3,1'), 0.15)

    fly.width = fly.sprite:getWidth()
    fly.height = fly.sprite:getHeight()
    fly.state = 'flying'
    fly.offset = offset
    fly.rotation = 0

    return fly
end

--------------------------

function Cow.new(node)
    local cow = {}
    setmetatable(cow, Cow)

    cow.x = node.x
    cow.y = node.y
    cow.width = node.width
    cow.height = node.height
    
    cow.offset = {
        x = -65,
        y = 0
    }
    
    cow.looking = 'straight'

    local gamesave = app.gamesaves:active()
    if gamesave:get('blacksmith-dead', false) then
        cow:die()
    else
        cow.state = cow.looking
    end

    cow.blinkdelay = 0
    cow.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds

    cow.fly = false
    
    return cow
end

function Cow:die()
    self.state = 'dead'
    if self.fly == false then
        self.fly = Fly.new(self, 0)
    end
end

function Cow:update(dt, player)
    if self.fly ~= false then
        self.fly.rotation = self.fly.rotation + 0.75 * dt
        self.fly.animation:update(dt)
    end

    local gamesave = app.gamesaves:active()
    if gamesave:get('blacksmith-dead', false) and self.state == 'dead' then
        self:die()
    else
        self.blinkdelay = self.blinkdelay + dt
        if self.blinkdelay >= self.nextblink then
            self.state = 'blink'
            if self.blinkdelay >= self.nextblink + 0.5 then
                self.state = self.looking
                self.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds
                self.blinkdelay = 0
            end
        elseif player.position.x <= self.x + self.offset.x then
            self.looking = 'left'
            if player.position.y <= self.y + self.offset.y then
                self.looking = 'up_left'
            end
            self.state = self.looking
        elseif player.position.x >= self.x + self.width + self.offset.x then
            self.looking = 'right'
            if player.position.y <= self.y + self.offset.y then
                self.looking = 'up_right'
            end
            self.state = self.looking
        else
            self.looking = 'straight'
            if player.position.y <= self.y + self.offset.y then
                self.looking = 'up'
            end
            self.state = self.looking
        end
    end
end

function Cow:draw()
    states[self.state]:draw(image, self.x, self.y)
    if self.fly ~= false then
        local x = self.x + (self.width / 2) + 10 + math.cos(self.fly.rotation * math.pi + self.fly.offset) * self.width / 2.5
        local y = self.y - 8 + math.sin(self.fly.rotation * math.pi) * 8
        self.fly.animation:draw(self.fly.sprite, x, y)
    end
end

return Cow
