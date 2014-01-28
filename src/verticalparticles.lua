local window = require 'window'

local Particle = {}
Particle.__index = Particle

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
  love.graphics.setPointSize(self.size)
  love.graphics.setPointStyle("rough")
  love.graphics.point(self.pos.x, self.pos.y)
end

local VerticalParticles = {}

local particleCount = 100
local particles = {}

-- Generate the requested number of particles
function VerticalParticles.init()
  particles = {}

  for i = 1,particleCount do
    table.insert(particles, Particle:new())
  end
end

function VerticalParticles.update(dt)
  for _,particle in ipairs(particles) do 
    particle:update(dt)
  end
end

function VerticalParticles.draw()
  love.graphics.setColor(255, 255, 255, 255)
  for _,particle in ipairs(particles) do
    particle:draw()
  end
end

function VerticalParticles.leave()
  particles = {}
end


return VerticalParticles
