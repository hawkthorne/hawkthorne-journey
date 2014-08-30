local anim8 = require 'vendor/anim8'
local app = require 'app'

local Fire = {}
Fire.__index = Fire
Fire.isFire = true

local image = love.graphics.newImage('images/fire.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(25, 25, image:getWidth(), image:getHeight())

local states = {
    burning = anim8.newAnimation('loop', g('1-8,1'), 0.25)
}

---
-- Creates a new Fire object
-- @param parent the parent node that the fire are added to
function Fire.new(parent, position)
    local fire = {}
    setmetatable(fire, Fire)
    
    fire.state = 'burning'

    fire.x = position.x or parent.x + math.random(-10, 10)
    fire.y = position.y or parent.y + math.random(-10, 0)

    return fire
end

function Fire:update(dt)
    states[self.state]:update(dt)
end

function Fire:draw()
    states[self.state]:draw(image, self.x, self.y)
end

return Fire
