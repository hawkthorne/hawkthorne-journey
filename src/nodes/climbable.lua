local Helper = require 'helper'

local Climbable = {}
Climbable.__index = Climbable

function Climbable.new(node, collider)
	local climbable = {}
	setmetatable(climbable, Climbable)
	climbable.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	climbable.bb.node = climbable
    climbable.collider = collider
	climbable.collider:setPassive(climbable.bb)

    climbable.position = {x=node.x, y=node.y}
	climbable.width = node.width
	climbable.height = node.height
    climbable.climb_speed = 2

	return climbable
end

function Climbable:draw()
end

function Climbable:collide(player, dt, mtv_x, mtv_y)
    player:registerHoldable(self)
end

function Climbable:collide_end(player, dt)
    player:cancelHoldable(self)
end

function Climbable:held(player)
    return (player.currently_held == self)
end

function Climbable:update(dt, player)
    local climb_down = love.keyboard.isDown('down') or love.keyboard.isDown('s')
    local climb_up   = love.keyboard.isDown('up') or love.keyboard.isDown('w')
    local escape_key = love.keyboard.isDown('left') or love.keyboard.isDown('a') or love.keyboard.isDown('right') or love.keyboard.isDown('w')
    local climb_y = 0
    
    -- Try to respond to up and down keys by grabbing on
	if not self:held(player) and player.holdable == self and (climb_up or climb_down) then
        player:pickup()
    end

    -- Abort if the player still has not grabbed on
	if not self:held(player) then
		return
	end

    -- Check to make sure we still have physical contact and have not released
    if player.holdable ~= self or player.position.y >= (self.position.y + self.height) or escape_key then
        player:drop()
        return
    end

    if climb_up then
        climb_y = -self.climb_speed
    elseif climb_down then
        climb_y = self.climb_speed
    end

    player.velocity.x = 0
    player.velocity.y = 0
    player.position.x = self.position.x - math.floor(self.width/2)
    player.position.y = player.position.y + climb_y
end

function Climbable:moveBoundingBox()
	Helper.moveBoundingBox(self)
end

function Climbable:pickup(player)
    player:setSpriteStates('climbing')
    player.physics_on = false
    player.velocity.x = 0
    player.velocity.y = 0
    player.position.x = self.position.x
end

function Climbable:throw(player)
    self:drop(player)
    player.velocity.y = player.velocity.y - 100
end

function Climbable:throw_vertical(player)
    self:drop(player)
    player.velocity.y = player.velocity.y - 300
end

function Climbable:drop(player)
    player.physics_on = true
    player:cancelHoldable(self)
end

return Climbable


