local Pot = {}
Pot.__index = Pot

local image_cache = {}

local function load_image(name)
	if image_cache[name] then
		return image_cache[name]
	end

	local image = love.graphics.newImage(name)
	image:setFilter('nearest', 'nearest')
	image_cache[name] = image
	return image
end

function Pot.new(node, collider)
	local pot = {}
	setmetatable(pot, Pot)
	pot.image = load_image('images/pot.png')
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
	self.bb:moveTo(self.position.x + self.width / 2,
				   self.position.y + (self.height / 2) + 2)
end

function Pot:held(player)
	self.position.x = math.floor(player.position.x + self.bb._polygon._radius) - 3
	self.position.y = math.floor(player.position.y - self.bb._polygon._radius) - 5
	self:moveBoundingBox()
end

function Pot:keypressed(key, player)
	if key == "return" then
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

