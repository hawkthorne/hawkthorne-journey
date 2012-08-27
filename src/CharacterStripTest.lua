require "CharacterStrip"

stripTest = {}

function stripTest.load()
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
		strips[i].x = 400 + ((10 + 80 * x) * (flip and -1 or 1))
		strips[i].y = 160 + 80 * x
	end
end

function stripTest.draw()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 191, 0)

	for _,strip in ipairs(strips) do strip:draw() end
end

function stripTest.update(dt)
	time = (time or 0) + dt
	for i,strip in ipairs(strips) do
		strip.slideOut = time > i

		strip:update(dt)
	end
end

return stripTest