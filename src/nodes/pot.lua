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

	pot.x = node.x
	pot.y = node.y

	return pot
end

function Pot:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function Pot:collide(player, dt, mtv_x, mtv_y)
	player:registerHoldable(self)
end

function Pot:collide_end(player, dt)
	player:cancelHoldable(self)
end

function Pot:throw()
	io.stdout:write("Pot:throw()\n")
	io.flush()
end

function Pot:held(player)
	self.x = math.floor(player.position.x + self.bb._polygon._radius) - 3
	self.y = (math.floor(player.position.y - self.bb._polygon._radius)) - 5
end


return Pot

