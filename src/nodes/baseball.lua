local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local window = require 'window'

local Baseball = {}
Baseball.__index = Baseball
Baseball.baseball = true

local BaseballImage = love.graphics.newImage('images/baseball.png')
local g = anim8.newGrid(9, 9, BaseballImage:getWidth(), BaseballImage:getHeight())

local game = {}
game.step = 10000
game.friction = 0.0146875 * game.step
game.accel = 0.046875 * game.step
game.deccel = 0.5 * game.step
game.gravity = 0.21875 * game.step
game.airaccel = 0.09375 * game.step
game.airdrag = 0.96875 * game.step
game.max_x = 300
game.max_y= 600

function Baseball.new(node, collider)
	local baseball = {}
	setmetatable(baseball, Baseball)
	baseball.image = BaseballImage
	baseball.foreground = node.properties.foreground
	baseball.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	baseball.bb.node = baseball
    baseball.collider = collider
    baseball.spinning = anim8.newAnimation('loop', g('1-2,1'), .10)

	baseball.position = { x = node.x, y = node.y }
	baseball.velocity = { x = -230, y = -200 }

	baseball.floor = node.layer.map.objectLayers.floor.objects[1].y - node.height
	baseball.thrown = true
	baseball.held = false
	baseball.rebounded = false

	baseball.width = node.width
	baseball.height = node.height
	
	return baseball
end

function Baseball:draw()
    if self.thrown then
        self.spinning:draw(BaseballImage, self.position.x, self.position.y)
    else
		love.graphics.drawq(self.image, love.graphics.newQuad( 0, 0, 9, 9, 18, 9 ), self.position.x, self.position.y)
	end
end

function Baseball:collide(node, dt, mtv_x, mtv_y)
	if node and node.character then
		node:registerHoldable(self)
	end
end

function Baseball:collide_end(node, dt)
	if node and node.character then
		node:cancelHoldable(self)
	end
end

function Baseball:update(dt, player)
    if self.held then
        self.position.x = math.floor(player.position.x) + (self.width / 2) + 15
        self.position.y = math.floor(player.position.y) + player.hand_offset - self.height + 2
	    self:moveBoundingBox()
	end

	if self.thrown then

		self.spinning:update(dt)

	    if self.velocity.x < 0 then
	        self.velocity.x = math.min(self.velocity.x + game.friction * dt, 0)
	    else
	        self.velocity.x = math.max(self.velocity.x - game.friction * dt, 0)
	    end

	    self.velocity.y = self.velocity.y + game.gravity * dt

	    if self.velocity.y > game.max_y then
	        self.velocity.y = game.max_y
	    end
	
	    self.position.x = self.position.x + self.velocity.x * dt
	    self.position.y = self.position.y + self.velocity.y * dt

		if self.position.x < 0 then
			self.position.x = 0
			self.rebounded = false
			self.velocity.x = -self.velocity.x
		end

		if self.position.x + self.width > window.width then
			self.position.x = window.width - self.width
			self.rebounded = false
			self.velocity.x = -self.velocity.x
		end

		current_y_velocity = self.velocity.y
		if self.thrown and self.position.y > self.floor then
			self.rebounded = false
			if current_y_velocity < 5 then
				--stop bounce
				self.velocity.y = 0
				self.position.y = self.floor
				self.thrown = false
			else
				--bounce 
				self.velocity.y = -.8 * math.abs( current_y_velocity )
			end
		end
	
	end
	
	self:moveBoundingBox()
	
end

function Baseball:moveBoundingBox()
	Helper.moveBoundingBox(self)
end

function Baseball:keypressed(key, player)
	if (key == "rshift" or key == "lshift") then
		if player.holdable == self then
			if player.holding == nil then
	            player.walk_state = 'holdwalk'
	            player.gaze_state = 'holdwalk'
	            player.crouch_state = 'holdwalk'
	            player.holding = true
	            self.held = true
				self.thrown = false
				self.velocity.y = 0
				self.velocity.x = 0
			else
				player.holding = nil
	        	player.walk_state = 'walk'
	            player.crouch_state = 'crouch'
	            player.gaze_state = 'gaze'
	            self.held = false
				self.thrown = true
				self.velocity.x = ( ( ( player.direction == "left" ) and -1 or 1 ) * 500 ) + player.velocity.x
				self.velocity.y = -800
			end
		end
	end
end

---
-- Gets the current acceleration speed
-- @return Number the acceleration to apply
function Baseball:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

---
-- Gets the current deceleration speed
-- @return Number the deceleration to apply
function Baseball:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end

function Baseball:rebound( x_change, y_change )
	if not self.rebounded then
		if x_change then
			self.velocity.x = -( self.velocity.x / 2 )
		end
		if y_change then
			self.velocity.y = -self.velocity.y
		end
		self.rebounded = true
	end
end


return Baseball

