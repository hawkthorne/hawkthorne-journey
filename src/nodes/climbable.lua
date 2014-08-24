local game = require 'game'

local Climbable = {}
Climbable.__index = Climbable

function Climbable.new(node, collider)
    local climbable = {}
    setmetatable(climbable, Climbable)
    climbable.props = node.properties
    climbable.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    climbable.bb.node = climbable
    climbable.collider = collider
    climbable.collider:setPassive(climbable.bb)

    climbable.position = {x=node.x, y=node.y}
    climbable.width = node.width
    climbable.height = node.height
    climbable.climb_speed = 100
    climbable.prev_state = 'default'

    return climbable
end

function Climbable:collide( node, dt, mtv_x, mtv_y )
    if not node.isPlayer then return end
    local player = node
    local player_base = player.position.y + player.height
    local self_base = self.position.y + self.height
    local controls = player.controls

    if not player.isClimbing and not controls:isDown('JUMP') and not player.controlState:is('ignoreMovement') then
        if ( controls:isDown('UP') and player_base > self.position.y + 10 ) or
           ( controls:isDown('UP') and node.velocity.y ~= 0 ) or
           ( controls:isDown('DOWN') and player_base < self_base - 10 and player_base > self.position.y + 10 ) then
            self:grab( player )
        end
    end

    local p_width = player.bbox_width
    local p_x = player.position.x + ( player.width / 2 ) - ( p_width / 2 )
    if player.isClimbing and ( 
        -- player is wider than the ladder, make sure no x movement
        ( p_width >= self.width and controls:isDown('LEFT') ) or
        ( p_width >= self.width and controls:isDown('RIGHT') )
    ) then
        player.position.x = ( self.position.x + self.width / 2 ) - player.character.bbox.width / 2

    elseif player.isClimbing and ( player.jumping or
        -- player is smaller than the ladder, make sure their center stays within the bounds
        ( p_width < self.width and 
            ( p_x + p_width / 2 < self.position.x or 
                p_x + p_width / 2 > self.position.x + self.width )
        )
    ) then
        self:release( player )
    end

    if not player.isClimbing then return end

    player.fall_damage = 0
    player.velocity.y = -(game.gravity * dt) / 2 -- prevent falling
    player.velocity.x = player.velocity.x * 0.8 -- horizontal resistance
    player.since_solid_ground = 0

    if controls:isDown('UP') and not player.controlState:is('ignoreMovement') and not player.freeze then
        if self.props and self.props.blockTop and player.position.y < self.position.y - 10 then
            player.position.y = self.position.y - 10
        else
            player.position.y = player.position.y - ( dt * self.climb_speed )
        end
    elseif controls:isDown('DOWN') and not player.controlState:is('ignoreMovement') and not player.freeze then
        player.position.y = player.position.y + ( dt * self.climb_speed )
    end

    if player_base > self_base - 5 and controls:isDown('DOWN') then
        self:release( player )
    end
end

function Climbable:collide_end( node )
    if node.isPlayer then
        self:release( node )
    end
end

function Climbable:grab( player )
    self.prev_state = player.current_state_set
    if player.bbox_width >= self.width then
        player.position.x = ( self.position.x + self.width / 2 ) - player.character.bbox.width / 2
    end
    player.velocity.x = 0
    player.jumping = false
    player.isClimbing = self
    player:setSpriteStates('climbing')
end

function Climbable:release( player )
    local state = player.currently_held and 'wielding' or 'default'
    player:setSpriteStates(state)
    player.isClimbing = false
end

return Climbable


