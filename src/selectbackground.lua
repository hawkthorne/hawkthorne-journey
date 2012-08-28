require "characterstrip"
ParticleSystem = require "particlesystem"

local window = require 'window'

stripTest = {}

function stripTest.load()
	love.graphics.setMode(912, 528)
	love.graphics.setCaption("Hawkthorne Character Select Test [Jyrroe]")

	strips = {}

	strips[1] = CharacterStrip:new(149,214,200,  69,  5, 19)
	strips[2] = CharacterStrip:new(134, 60,133,  87,156, 94)
	strips[3] = CharacterStrip:new(171, 98,109,  43,117,111)
	strips[4] = CharacterStrip:new( 80, 80, 80, 140,140,140)
	strips[5] = CharacterStrip:new( 81, 73,149, 137,142, 72)
	strips[6] = CharacterStrip:new(150,221,149,  65,  0, 72)
	strips[7] = CharacterStrip:new(200,209,149,  26,  3, 72)
	strips[8] = CharacterStrip:new(173,135,158,  48, 82, 68)

	for i = 1,8 do
		flip = i > 4
		x = (i-1) % 4
		strips[i].flip = flip
		strips[i].x = window.width/2 + ((14 + 68 * x) * (flip and -1 or 1))
		strips[i].y = 130 + 68 * x
	end

	ParticleSystem:init()
end

function stripTest.draw()
	love.graphics.setBackgroundColor(0, 0, 0, 0)

	ParticleSystem.draw()

	for _,strip in ipairs(strips) do strip:draw() end

	love.graphics.setColor(255, 255, 255)
end

function stripTest.update(dt)
	ParticleSystem.update(dt)

	--time = (time or 0) + dt
	for i,strip in ipairs(strips) do
		--strip.slideOut = time*3 > ((i-1) % 4 + 2)

		strip:update(dt)
	end
end

return stripTest