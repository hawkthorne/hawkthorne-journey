----------------------------------------------------------------------
-- particle.lua
-- Defines a single particle for the starry select menu background.
-- Created by tjvezina
----------------------------------------------------------------------

Particle = {}
Particle.__index = Particle

local window = require 'window'

function Particle:new()
    new = {}
    setmetatable(new, Particle)

    local winWidth = window.width

    new.size = math.random(3)
    new.pos = { x = math.random(winWidth), y = math.random(window.height) }

    local ratio = 1.0 - math.cos(math.abs(new.pos.x - winWidth/2) * 2 / winWidth) * 0.6

    new.speed = 300 * (ratio + math.random()/4)

    return new
end

-- Loop each particle repeatedly over the screen
function Particle:update(dt)
    self.pos.y = self.pos.y - (dt * self.speed)

    if self.pos.y < 0 then self.pos.y = window.height end
end

function Particle:draw()
    love.graphics.setPoint(self.size, "rough")
    love.graphics.point(self.pos.x, self.pos.y)
end