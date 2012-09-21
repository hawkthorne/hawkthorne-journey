----------------------------------------------------------------------
-- characterstrip.lua
-- A single colored strip, on which a character appears for selection.
-- Created by tjvezina
----------------------------------------------------------------------

CharacterStrip = {}
CharacterStrip.__index = CharacterStrip

local window = require 'window'

local stripSize = 35	-- Thickness of the strip
local moveSize = 300	-- Pixels travelled from ratio 0 to 1
local moveSpeed = 5.0	-- Slide speed multiplier
-- The different colored bars on the strip appear at these intervals
local colorSpacing = { 140, 160, 180, 200, 220 }

-- Hawkthorne Colors (As arranged on-screen):
-- NOTE: Each strips 2nd color is calculated by (220-r, 220-g, 220-b)
--    ( 81,  73, 149) | (149, 214, 200)
--   (150, 221, 149)  |  (134,  60, 133)
--  (200, 209, 149)   |   (171,  98, 109)
-- (173, 135, 158)    |    ( 80,  80,  80)

function CharacterStrip:new(r, g, b)
	new = {}
	setmetatable(new, CharacterStrip)

	new.x = 0
	new.y = 0
	new.flip = false

	new.ratio = 0
	new.slideOut = false

	new.color1 = { r = r, g = g, b = b }
	new.color2 = { r = 220-r, g = 220-g, b = 220-b }

    new.bounce_pos = 0
    new.bounce = 0
    new.bounce_speed = 8
    new.bounce_offset = 10

	return new
end

function CharacterStrip:getCharacterPos()
	local x = self.x + (self.flip and 44 or -44) - self:getOffset() - ( self.bounce * (self.flip and -1 or 1) ) / 4
	local y = self.y

    if not self.flip then
        local limit = self.x + 10
        if x > limit then
            y = y + (x - limit)
            x = limit
        end
    else
        local limit = self.x - 10
        if x < limit then
            y = y + (limit - x)
            x = limit
        end
    end

	return x, y
end

function CharacterStrip:draw()
	w = window.width * 0.5
	h = window.height * 0.75

	local stencilFunc = nil
	if self.flip then
		stencilFunc = function()
			love.graphics.rectangle('fill', self.x, self.y, w, stripSize)
			love.graphics.rectangle('fill', self.x, self.y + stripSize,
				stripSize, math.max(moveSize * self.ratio - stripSize, 0))
		end
	else
		stencilFunc = function()
			love.graphics.rectangle('fill', self.x - w, self.y, w, stripSize)
			love.graphics.rectangle('fill', self.x - stripSize, self.y + stripSize,
				stripSize, math.max(moveSize * self.ratio - stripSize, 0))
		end
	end

	love.graphics.setStencil( stencilFunc )

	for i = 1,#colorSpacing do
		color = self:getColor((i-1) / (#colorSpacing-1))
        love.graphics.setColor(color.r, color.g, color.b, 255)
		love.graphics.polygon('fill', self:getPolyVerts(i))
	end

	love.graphics.setStencil()
end

local time = 0
function CharacterStrip:update(dt,ready)
	self.ratio = self.ratio + dt * moveSpeed
	if not self.slideOut then
		self.ratio = math.min(self.ratio, 0)
	end
    if self.selected and ready then
        self.bounce_pos = (self.bounce_pos + self.bounce_speed*dt) % ( math.pi * 2 )
        self.bounce = self.bounce_offset - math.cos(self.bounce_pos) * self.bounce_offset
    else
        self.bounce = 0
        self.bounce_pos = 0
    end
end

function CharacterStrip:getPolyVerts(segment)
	local offset = -self:getOffset() - ( self.bounce * (self.flip and -1 or 1) )

	local verts = {}

	if self.flip then
		verts[1] = offset + self.x + (colorSpacing[segment-1] or 0)
		verts[2] = self.y
		verts[3] = offset + self.x + colorSpacing[segment]
		verts[4] = self.y
		verts[5] = verts[3] + moveSize
		verts[6] = verts[4] + moveSize
		verts[7] = verts[1] + moveSize
		verts[8] = verts[2] + moveSize
	else
		verts[1] = offset + self.x - (colorSpacing[segment-1] or 0)
		verts[2] = self.y
		verts[7] = offset + self.x - colorSpacing[segment]
		verts[8] = self.y
		verts[5] = verts[7] - moveSize
		verts[6] = verts[8] + moveSize
		verts[3] = verts[1] - moveSize
		verts[4] = verts[2] + moveSize
	end

	return verts
end

function CharacterStrip:getColor(ratio)
	assert(ratio >= 0 and ratio <= 1, "Color ratio must be between 0 and 1.")

	if ratio == 0 then return self.color1 end
	if ratio == 1 then return self.color2 end

	colorDif = { r = self.color2.r - self.color1.r,
				 g = self.color2.g - self.color1.g,
				 b = self.color2.b - self.color1.b }

	return { r = self.color1.r + ( colorDif.r * ratio ),
			 g = self.color1.g + ( colorDif.g * ratio ),
			 b = self.color1.b + ( colorDif.b * ratio ) }
end

function CharacterStrip:getOffset()
	return ( (self.flip and -moveSize or moveSize) * -self.ratio )
end
