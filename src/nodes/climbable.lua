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

    if not player.isClimbing and not player.controls:isDown('JUMP') then
        if ( player.controls:isDown('UP') and player_base > self.position.y + 10 ) or
           ( player.controls:isDown('UP') and node.velocity.y ~= 0 ) or
           ( player.controls:isDown('DOWN') and player_base < self_base - 10 and player_base > self.position.y + 10 ) then
            self:grab( player )
        end
    end

    local p_width = player.bbox_width
    local p_x = player.position.x + ( player.width / 2 ) - ( p_width / 2 )

    if player.isClimbing and ( player.jumping or
        -- player is wider than the ladder, make sure no x movement
        ( p_width >= self.width and player.controls:isDown('LEFT') ) or 
        ( p_width >= self.width and player.controls:isDown('RIGHT') ) or
        -- player is smaller than the ladder, make sure their center stays within the bounds
        ( p_width < self.width and 
            ( p_x + p_width / 2 < self.position.x or 
                p_x + p_width / 2 > self.position.x + self.width )
        )
    ) then
        self:release( player )
    end

    if not player.isClimbing or player.interactive_collide then return end

    player.fall_damage = 0
    player.velocity.y = -(game.gravity * dt) / 2 -- prevent falling
    player.velocity.x = player.velocity.x * 0.8 -- horizontal resistance
    player.since_solid_ground = 0

    if player.controls:isDown('UP') and not player.controlState:is('ignoreMovement') then
        player.position.y = player.position.y - ( dt * self.climb_speed )
    elseif player.controls:isDown('DOWN') and not player.controlState:is('ignoreMovement') then
        player.position.y = player.position.y + ( dt * self.climb_speed )
    end

    if player_base > self_base - 5 and player.controls:isDown('DOWN') then
        self:release( player )
    end
end

function Climbable:collide_end( node )
    if node.isPlayer then
        self:release( node )
    end
end

function Climbable:grab( player )
    if player.bbox_width >= self.width then
        player.position.x = ( self.position.x + self.width / 2 ) - player.width / 2
    end
    player.velocity.x = 0
    player.jumping = false
    player.isClimbing = true
    player:setSpriteStates('climbing')
end

function Climbable:release( player )
    if player.isClimbing then
        player:setSpriteStates(player.previous_state_set)
    end
    player.isClimbing = false
end

return Climbable


