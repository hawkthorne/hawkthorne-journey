local Wall = {}
Wall.__index = Wall

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    wall.node = node
    collider:setPassive(wall.bb)
    wall.isSolid = true

    return wall
end

function Wall:collide( node, dt, mtv_x, mtv_y)
    if not (node.wall_collide_floor or node.wall_collide_side) then return end
    local player = node
    
    local _, wy1, _, wy2 = self.bb:bbox()

    -- if player is crouching ( sliding or not ) and the bottom of the wall is higher than the crouch height, allow it.
    if player.isPlayer and player.state == player.crouch_state and wy2 < player.position.y + player.bbox_height / 2 then
        player.wall_duck = true
        return
    end

    if mtv_x ~= 0 and player.wall_collide_side then
        -- horizontal block
        player:wall_collide_side(self, player.position.x+mtv_x)
    end

    if mtv_y > 0 and player.wall_collide_head then
        if player.wall_duck then
            -- player standing up from crouch
            player.state = player.crouch_state
            player.position.x = player.position.x + ( 5 * ( player.direction == 'right' and 1 or -1 ) )
        else
            -- bouncing off bottom
            player:wall_collide_head(self, player.position.y + mtv_y)
        end
    end
    
    if mtv_y < 0 then
        -- standing on top
        player:wall_collide_floor(self, self.node.y - player.height)
    end
end

function Wall:collide_end( node ,dt )
    if node.isPlayer then
        node.wall_duck = false
    end
end

return Wall

