local anim8 = require 'vendor/anim8'
local Helper = require 'helper'

local Pot = {}
Pot.__index = Pot

local potImage = love.graphics.newImage('images/pot.png')
local potExplode= love.graphics.newImage('images/pot_asplode.png')
local g = anim8.newGrid(41, 30, potExplode:getWidth(), potExplode:getHeight())


function Pot.new(node, collider)
	local pot = {}
	setmetatable(pot, Pot)
	pot.image = potImage
	pot.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	pot.bb.node = pot
    pot.collider = collider
	pot.collider:setPassive(pot.bb)
    pot.explode = anim8.newAnimation('once', g('1-5,1'), .10)

	pot.position = { x = node.x, y = node.y }
	pot.velocity = { x = 0, y = 0 }

	pot.floor = 0
    pot.die = false
	pot.thrown = false
    pot.held = false

	pot.width = node.width
	pot.height = node.height

	return pot
end

function Pot:draw()
    if self.die then
        self.explode:draw(potExplode, self.position.x, self.position.y)
    else
	    love.graphics.draw(self.image, self.position.x, self.position.y)
    end
end

function Pot:collide(player, dt, mtv_x, mtv_y)
	player:registerHoldable(self)
    if self.held then
        self.position.x = math.floor(player.position.x + (self.width / 2))
        self.position.y = math.floor(player.position.y - self.height / 2)
        self:moveBoundingBox()
    end
end

function Pot:collide_end(player, dt)
	player:cancelHoldable(self)
end

function Pot:update(dt, player)
    if self.die and self.explode.position ~= 5 then
        self.explode:update(dt)
        self.position.x = self.position.x + 50 * dt
        return
    end

	if not (self.thrown or self.held) then
		return
	end

	self.velocity.y = self.velocity.y + 0.21875 * 10000 * dt

    if not self.held then
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
    end

	if self.position.x < 0 then
		self.position.x = 0
		self.thrown = false
	end

	if self.position.x > 400 then
		self.position.x = 400
		self.thrown = false
	end

	if self.thrown and self.position.y > self.floor then
		self.position.y = self.floor
		self.thrown = false
        self.die = true
	end
end

function Pot:moveBoundingBox()
	Helper.moveBoundingBox(self)
end

function Pot:keypressed(key, player)
	if key == "rshift" or key == "lshift" then
		if player.holding == nil then
			player.holding = player.holdable
            self.held = true
			self.velocity.y = 0
			self.velocity.x = 0
		else
			player.holding = nil
            self.held = false
			self.thrown = true
			self.floor = player.position.y + player.height - self.height
			self.velocity.x = ((player.direction == "left") and -1 or 1) * 500
			self.velocity.y = 0
            self.collider:setGhost(self.bb)
		end
	end
end

return Pot

