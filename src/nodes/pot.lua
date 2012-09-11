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
    if not player.holding then
        player:registerHoldable(self)
    end
end

function Pot:collide_end(player, dt)
    player:cancelHoldable(self)
end

function Pot:update(dt, player)
    if self.held then
        self.position.x = math.floor(player.position.x + (self.width / 2)) + 2
        self.position.y = math.floor(player.position.y + player.hand_offset_y - self.height)
        self:moveBoundingBox()
        return
    end
    
    if self.die and self.explode.position ~= 5 then
        self.explode:update(dt)
        self.position.x = self.position.x + (self.velocity.x > 0 and 1 or -1) * 50 * dt
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
		self.velocity.x = -self.velocity.x
	end

	if self.position.x > 400 then
		self.velocity.x = -self.velocity.x
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
	if (key == "rshift" or key == "lshift") and player.holdable == self then
		if player.holding == nil then
            player.walk_state = 'holdwalk'
            player.gaze_state = 'holdwalk'
            player.crouch_state = 'holdwalk'
            player.holding = true
            self.held = true
			self.velocity.y = 0
			self.velocity.x = 0
		else
			player.holding = nil
            player.walk_state = 'walk'
            player.crouch_state = 'crouchwalk'
            player.gaze_state = 'gazewalk'
            self.held = false
			self.thrown = true
			self.floor = player.position.y + player.height - self.height
			self.velocity.x = ((player.direction == "left") and -1 or 1) * 500
			self.velocity.y = 0
            self.collider:setGhost(self.bb)
            player:cancelHoldable(self)
		end
	end
end

return Pot

