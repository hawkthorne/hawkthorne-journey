local controls = require 'controls'
local game = require 'game'

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
    climbable.climb_speed = 100

	return climbable
end

function Climbable:collide( node, dt, mtv_x, mtv_y )
    if not node.isPlayer then return end
    local player = node
    local player_base = player.position.y + player.height
    local self_base = self.position.y + self.height

    if not player.isClimbing then
        print(node.velocity.y)
        if ( controls.isDown('UP') and player_base > self.position.y + 10 ) or
           ( controls.isDown('UP') and node.velocity.y ~= 0 ) or
           ( controls.isDown('DOWN') and player_base < self_base - 10 ) then
            self:grab( player )
        end
    end

    if player.isClimbing and ( player.velocity.x ~=0 or player.jumping ) then
        self:release( player )
    end

    if not player.isClimbing or player.interactive_collide then return end

    player.velocity = {x=0,y=-game.gravity * dt}
    player.position.x = ( self.position.x + self.width / 2 ) - player.width / 2
    player.since_solid_ground = 0

    if controls.isDown('UP') and not player.controlState:is('ignoreMovement') then
        player.position.y = player.position.y - ( dt * self.climb_speed )
    elseif controls.isDown('DOWN') and not player.controlState:is('ignoreMovement') then
        player.position.y = player.position.y + ( dt * self.climb_speed )
    end

    if player_base > self_base - 5 and controls.isDown('DOWN') then
        self:release( player )
    end
end

function Climbable:collide_end( node )
    if node.isPlayer then
        self:release( node )
    end
end

function Climbable:grab( player )
    player.jumping = false
    player.isClimbing = true
    player:setSpriteStates('climbing')
end

function Climbable:release( player )
    player.isClimbing = false
    player:setSpriteStates('default')
end

return Climbable


