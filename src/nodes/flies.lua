local anim8 = require 'vendor/anim8'
local app = require 'app'

local Flies = {}

Flies.__index = Flies

local image = love.graphics.newImage('images/sprites/town/fly.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(5,5, image:getWidth(), image:getHeight())

local states = {
    flying = anim8.newAnimation('loop',g('1-3,1'), 0.15)
}

function Flies.new(node, count)
    local flies = {}
    setmetatable(flies, Flies)

    flies.parent = node

    flies.state = 'flying'
    flies.rotation = 0
    flies.count = count

    return flies
end

function Flies:update(dt)
    self.rotation = self.rotation + 1.75 * dt
    states[self.state]:update(dt)
end

function Flies:draw()
    for i=1,self.count do
        local x = self.parent.x + (self.parent.width / 2) + 10 + math.cos(self.rotation + i * math.pi / self.count + 1) * self.parent.width / 2.5
        local y = self.parent.y - 5 + math.sin(self.rotation + i * math.pi / self.count + 1) * 5
        states[self.state]:draw(image, x, y)
    end
end

return Flies
