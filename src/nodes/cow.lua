local anim8 = require 'vendor/anim8'

local Cow = {}

Cow.__index = Cow

local image = love.graphics.newImage('images/cow.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(84,60, image:getWidth(), image:getHeight())

local states = {
    left = anim8.newAnimation('once',g('1,1'), 1),
    right = anim8.newAnimation('once',g('2,1'), 1),
    up = anim8.newAnimation('once',g('3,1'), 1),
    up_left = anim8.newAnimation('once',g('1,2'), 1),
    up_right = anim8.newAnimation('once',g('2,2'), 1),
    straight = anim8.newAnimation('once',g('1,3'), 1),
    blink = anim8.newAnimation('once',g('2,3'), 1),
}

function Cow.new(node, collider)
    local cow = {}
    setmetatable(cow, Cow)

    cow.x = node.x
    cow.y = node.y
    cow.width = node.width
    cow.height = node.height
    
    cow.offset = {
        x = -50,
        y = 0
    }
    
    cow.looking = 'straight'
    cow.state = cow.looking
    cow.blinkdelay = 0
    cow.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds
    
    return cow
end

function Cow:update(dt, player)
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

function Cow:draw()
    states[self.state]:draw(image, self.x, self.y)
end

return Cow


