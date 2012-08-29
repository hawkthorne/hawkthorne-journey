----------------------------------------------------------------------
-- selectbackground.lua
-- The background details in the character select screen.
-- Created by tjvezina
----------------------------------------------------------------------

require "characterstrip"
ParticleSystem = require "particlesystem"

local window = require 'window'
local slideTime = 0
local unknownFriend = nil

selectBackground = {}


function selectBackground.load()
	ParticleSystem:init()

	unknownFriend = love.graphics.newImage('images/insufficient_friend.png')
end

function selectBackground.enter()
	selectBackground.speed = 1
	selectBackground.slideIn = false
	selectBackground.slideOut = false
	slideTime = 0;

	strips = {}

	strips[1] = CharacterStrip:new(149, 214, 200)
	strips[2] = CharacterStrip:new(134,  60, 133)
	strips[3] = CharacterStrip:new(171,  98, 109)
	strips[4] = CharacterStrip:new( 80,  80,  80)
	strips[5] = CharacterStrip:new( 81,  73, 149)
	strips[6] = CharacterStrip:new(150, 220, 149)
	strips[7] = CharacterStrip:new(200, 209, 149)
	strips[8] = CharacterStrip:new(173, 135, 158)
	
	for i = 1,8 do
		flip = i > 4
		x = (i-1) % 4
		strips[i].ratio = -(x * 2 + 1)
		strips[i].flip = flip
		strips[i].x = window.width/2 + ((7 + (27+7) * x) * (flip and -1 or 1))
		strips[i].y = 66 + (27+7) * x
	end
end

-- Renders the starry background and each strip
function selectBackground.draw()
	love.graphics.setBackgroundColor(0, 0, 0, 0)

	ParticleSystem.draw()

	for _,strip in ipairs(strips) do strip:draw() end

	love.graphics.setColor(255, 255, 255, 255)

	local x, y = strips[4]:getCharacterPos()
	love.graphics.draw(unknownFriend, x + 14, y + 2)
end

-- Updates the particle system and each strip
function selectBackground.update(dt)
	ParticleSystem.update(dt)

	sliding = selectBackground.slideIn or selectBackground.slideOut

	if not sliding then selectBackground.speed = 1 end

	if selectBackground.slideOut then
		slideTime = slideTime + (dt * selectBackground.speed)
	end

	for i,strip in ipairs(strips) do
		-- Tell the strips to slide out at the proper time
		strip.slideOut = (slideTime*4 > (i-1) % 4)
		strip:update(dt * selectBackground.speed)
	end

	-- Set 'slideIn' to false when the last strip is fully on-screen
	selectBackground.slideIn = (strips[8].ratio < 0)

	-- After a set delay, tell the caller it's safe to swap states
	return (slideTime > 1.25)
end

-- Returns the postion the strip's character should be drawing at
function selectBackground.getPosition(side, level)
	return strips[(level+1) + (side == 1 and 4 or 0)]:getCharacterPos()
end

return selectBackground