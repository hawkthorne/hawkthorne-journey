require "particle"

ParticleSystem = {}

local particleCount = 100
local particles = {}

function ParticleSystem.init()
	for i = 1,particleCount do
		table.insert(particles, Particle:new())
	end
end

function ParticleSystem.update(dt)
	for _,particle in ipairs(particles) do particle:update(dt) end
end

function ParticleSystem.draw()
	love.graphics.setColor(255, 255, 255)
	for _,particle in ipairs(particles) do particle:draw() end
end

return ParticleSystem