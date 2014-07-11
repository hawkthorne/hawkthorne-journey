local anim8 = require 'vendor/anim8'
local app = require 'app'
local Flies = require 'nodes/flies'

local Cow = {}

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

    cow.blinkdelay = 0
    cow.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds
    
    return cow
end

function Cow:enter()
    local gamesave = app.gamesaves:active()
    if gamesave:get('blacksmith-dead', false) then
        self:die()
    else
        self.state = self.looking
    end
end

function Cow:die()
    self.state = 'dead'

    local level = self.containerLevel
    level:addNode(Flies.new(self, 2))
end

function Cow:update(dt, player)
    -- If cow isn't not dead, do the usual looking around
    if self.state ~= 'dead' then
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
end

return Cow
