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

---
-- Creates a new Flies object
-- @param parent the parent node that the flies are added to
-- @param count of how many flies to add
function Flies.new(parent, count)
    local flies = {}
    setmetatable(flies, Flies)

    flies.parent = parent

    flies.state = 'flying'
    flies.rotation = 0
    flies.count = count
    flies.speed = 3.5

    flies.circle = {
        x = flies.parent.x + flies.parent.width / 2,
        y = flies.parent.y - 8,
        radius_x = flies.parent.width / 3,
        radius_y = 8
    }

    return flies
end

function Flies:update(dt)
    self.rotation = self.rotation + self.speed * dt
    states[self.state]:update(dt)
end

function Flies:draw()
    -- Loop through enough times to add all of the flies we want to add
    for i=1,self.count do
        -- x is the x axis on a circle that will be just less than the width of the parent node
        local x = self.circle.x + math.cos((self.rotation + i) * math.pi / (self.count + 1)) * self.circle.radius_x
        -- y is the y axis of a circle that has a squashed height to be located just above the parent node
        local y = self.circle.y + math.sin((self.rotation + i) * math.pi / (self.count + 1)) * self.circle.radius_y
        states[self.state]:draw(image, x, y)
    end
end

return Flies
