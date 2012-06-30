local Helper = require 'helper'

local Pot = {}
Pot.__index = Pot

local potImage = love.graphics.newImage('images/pot.png')
potImage:setFilter('nearest', 'nearest')

function Pot.new(node, collider)
	local pot = {}
	setmetatable(pot, Pot)
	pot.image = potImage
	pot.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	pot.bb.node = pot
	collider:setPassive(pot.bb)

	pot.position = { x = node.x, y = node.y }
	pot.velocity = { x = 0, y = 0 }

	pot.floor = 0
	pot.thrown = false

	pot.width = node.width
	pot.height = node.height

	return pot
end

function Pot:draw()
	love.graphics.draw(self.image, self.position.x, self.position.y)
end

function Pot:collide(player, dt, mtv_x, mtv_y)
	player:registerHoldable(self)
end

function Pot:collide_end(player, dt)
	player:cancelHoldable(self)
end

function Pot:update(dt)
	if not self.thrown then
		return
	end

	self.velocity.y = self.velocity.y + 0.21875 * 10000 * dt

	self.position.x = self.position.x + self.velocity.x * dt
	self.position.y = self.position.y + self.velocity.y * dt
	self:moveBoundingBox()

	if self.position.x < 0 then
		self.position.x = 0
		self.thrown = false
	end

	if self.position.x > 400 then
		self.position.x = 400
		self.thrown = false
	end

	if self.position.y > self.floor then
		self.position.y = self.floor
		self.thrown = false
	end
end

function Pot:moveBoundingBox()
	Helper.moveBoundingBox(self)
end

function Pot:held(player)
	self.position.x = math.floor(player.position.x + (self.width / 2))
	self.position.y = math.floor(player.position.y - self.height)
	self:moveBoundingBox()
end

function Pot:keypressed(key, player)
	if key == "rshift" or key == "lshift" then
		if player.holding == nil then
			player.holding = player.holdable
			self.velocity.y = 0
			self.velocity.x = 0
		else
			player.holding = nil
			self.floor = player.position.y + player.height - self.height
			self.velocity.x = ((player.direction == "left") and -1 or 1) * 500
			self.thrown = true
		end
	end
end

return Pot

