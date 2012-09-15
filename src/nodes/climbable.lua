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
    
    climbable.isbeingtouched = false
    climbable.isclimbing = false

	return climbable
end

function Climbable:collide(player, dt, mtv_x, mtv_y)
    self.isbeingtouched = true
end

function Climbable:collide_end(player, dt)
    self.isbeingtouched = false
    self:stop(player)
end

function Climbable:update(dt, player)
    -- Abort if the player is not touching
    if not self.isbeingtouched then
        return
    end
    
    local climb_down = love.keyboard.isDown('down') or love.keyboard.isDown('s')
    local climb_up   = love.keyboard.isDown('up') or love.keyboard.isDown('w')
    local escape_key = love.keyboard.isDown(' ') or love.keyboard.isDown('left') or love.keyboard.isDown('a') or love.keyboard.isDown('right') or love.keyboard.isDown('w')
    local climb_y = 0
    
    if self.climbing then
        -- Check to make sure we still have physical contact and have not released
        if player.position.y >= (self.position.y + self.height) or
           player.position.y + player.height > self.position.y + self.height and not climb_up or
           escape_key then
            self:stop(player)
            return
        end

        if climb_up then
            climb_y = -self.climb_speed
        elseif climb_down then
            climb_y = self.climb_speed
        end

        player.position.x = self.position.x - math.floor(self.width/2)
        player.position.y = player.position.y + climb_y

    else
        -- Try to respond to up and down keys by grabbing on
        if ( climb_up and player.position.y + player.height > self.position.y + 5 ) or --top of ladder
           ( climb_down and player.position.y + player.height + 5 < self.position.y + self.height ) then
            self:start(player)
        end
    end

end

function Climbable:start(player)
    self.climbing = true
    player:setSpriteStates('climbing')
    player.physics_on = false
end

function Climbable:stop(player)
    player.physics_on = true
    player:setSpriteStates()
    self.climbing = false
end

return Climbable


