----------------------------------------------------------------------
-- tunnelparticles.lua
-- Manages the particles for the flying character background.
-- Created by tjvezina
----------------------------------------------------------------------

TunnelParticle = {}
TunnelParticle.__index = TunnelParticle

local window = require 'window'
local maxDistance = math.sqrt((window.height / 2) ^ 2 + (window.width / 2) ^ 2)

function TunnelParticle:new()
  new = {}
  setmetatable(new, TunnelParticle)

  -- r = radius is the angle
  -- d = distance from origin
  -- s = speed is constant

  new.startSpeed = math.random(200, 500)
  new.radius = math.random((math.pi * 2 ) * 10000) / 10000
  new.distance = math.random(30, maxDistance)
  new.speed = new.startSpeed * (new.distance / maxDistance)
  new.spin = ((new.startSpeed - 200) / 500)

  return new
end

-- Loop each particle repeatedly over the screen
function TunnelParticle:update(dt)
  self.speed = self.startSpeed * (self.distance / maxDistance)
  self.distance = self.distance - dt * self.speed
  self.radius = self.radius + self.spin * dt

  if self.distance <= 30 then
    self.distance = maxDistance
  end
end

function TunnelParticle:draw()
  love.graphics.setPointSize((self.startSpeed / 50) * (self.distance / maxDistance))
  love.graphics.setPointStyle("rough")
  love.graphics.point(
    (window.width / 2) + (math.cos(self.radius) * self.distance),
    (window.height / 2) + (math.sin(self.radius) * self.distance)
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
  for _, particle in ipairs(particles) do 
    particle:update(dt)
  end
end

function TunnelParticles.draw()
  love.graphics.setColor( 255, 255, 255, 255 )
  for _, particle in ipairs(particles) do
    particle:draw()
  end
end

function TunnelParticles.leave()
  particles = {}
end


return TunnelParticles
