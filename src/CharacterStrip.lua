CharacterStrip = {}
CharacterStrip.__index = CharacterStrip

local stripSize = 70
local moveSize = 400
local moveSpeed = 3.0
local bounds = { w = 400, h = 600 }
local colorSpacing = { 280, 319, 358, 397, 436 }

-- Hawkthorne Colors:
-- ( 81, 73,149) -> (137,142, 72)	|	(149,214,200) -> ( 69,  5, 19)
-- (150,221,149) -> ( 65,  0, 72)	|	(134, 60,133) -> ( 87,156, 94)
-- (200,209,149) -> ( 26,  3, 72)	|	(171, 98,109) -> ( 43,117,111)
-- (173,135,158) -> ( 48, 82, 68)	|	( 80, 80, 80) -> (140,140,140)

function CharacterStrip:new(r1, g1, b1, r2, g2, b2)
	new = {}
	setmetatable(new, CharacterStrip)

	new.x = 0
	new.y = 0
	new.flip = false

	new.ratio = 0
	new.slideOut = false

	new.color1 = { r = r1, g = g1, b = b1 }
	new.color2 = { r = r2, g = g2, b = b2 }

	return new
end

function CharacterStrip:draw()
	if not self.flip then
		love.graphics.setScissor(self.x, self.y, bounds.w, stripSize)
	else
		love.graphics.setScissor(self.x-bounds.w, self.y, bounds.w, stripSize)
	end

	drawPolys(self)

	if not self.flip then
		love.graphics.setScissor(self.x, self.y, stripSize, bounds.h * self.ratio*0.6)
	else
		love.graphics.setScissor(self.x-stripSize, self.y, stripSize, bounds.h * self.ratio*0.6)
	end

	drawPolys(self)
	
	love.graphics.setScissor()
end

local time = 0
function CharacterStrip:update(dt)
	self.ratio = self.ratio + dt * moveSpeed
	if not self.slideOut then
		self.ratio = math.min(self.ratio, 0)
	end
end

function drawPolys(self)
	for i=1,#colorSpacing do
		color = self:getColor((i-1) / (#colorSpacing-1))
		love.graphics.setColor(color.r, color.g, color.b)
		love.graphics.polygon("fill", self:getPolyVerts(i))
	end
end

function CharacterStrip:getPolyVerts(segment)
	local offset = (self.flip and moveSize or -moveSize) * self.ratio

	local verts = {}

	if not self.flip then
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