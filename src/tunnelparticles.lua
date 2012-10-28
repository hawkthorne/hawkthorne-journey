----------------------------------------------------------------------
-- tunnelparticles.lua
-- Manages the particles for the flying character background.
-- Created by tjvezina
----------------------------------------------------------------------

TunnelParticle = {}
TunnelParticle.__index = TunnelParticle

local window = require 'window'
local maxDistance = math.max( window.height / 2, window.width / 2 ) * 1.5

function TunnelParticle:new()
    new = {}
    setmetatable(new, TunnelParticle)

    -- o = origin is always the center of the screen
    -- r = radius is the angle
    -- d = distance from origin
    -- s = speed is constant

    new.o = { x = window.width / 2, y = window.height / 2 }
    new.r = math.random( ( math.pi * 2 ) * 10000 ) / 10000
    new.d = math.random( 0, maxDistance )
    new.s = 150

    return new
end

-- Loop each particle repeatedly over the screen
function TunnelParticle:update(dt)
    self.d = self.d - dt * self.s
    self.r = self.r + 0.3 * dt
    
    if self.d <= 0 then
        self.d = maxDistance
    end
end

function TunnelParticle:draw()
    love.graphics.setPoint(self.d / 50, "rough")
    love.graphics.point(
        self.o.x + ( math.cos( self.r ) * self.d ),
        self.o.y + ( math.sin( self.r ) * self.d )
    )
end

TunnelParticles = {}

local particleCount = 200
local particles = {}

-- Generate the requested number of particles
function TunnelParticles.init()
    for i = 1,particleCount do
        table.insert(particles, TunnelParticle:new())
    end
end

function TunnelParticles.update(dt)
    for _,particle in ipairs(particles) do particle:update(dt) end
end

function TunnelParticles.draw()
    love.graphics.setColor(255, 255, 255)
    for _,particle in ipairs(particles) do particle:draw() end
end

return TunnelParticles