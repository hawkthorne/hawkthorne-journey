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

function Wall:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2 = self.bb:bbox()

    -- if player is crouching ( sliding or not ) and the bottom of the wall is higher than the crouch height, allow it.
    if player.state == player.crouch_state and wy2 < player.position.y + player.bbox_height / 2 then
        player.wall_duck = true
        return
    end

    if mtv_x ~= 0 then
        -- horizontal block
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
    end

    if mtv_y > 0 then
        if player.wall_duck then
            -- player standing up from crouch
            player.state = player.crouch_state
            player.position.x = player.position.x + ( 5 * ( player.direction == 'right' and 1 or -1 ) )
        else
            -- bouncing off bottom
            player.velocity.y = 0
            player.position.y = player.position.y + mtv_y
        end
    end
    
    if mtv_y < 0 then
        -- standing on top
        player.velocity.y = 0
        player.position.y = self.node.y - player.height
        player.jumping = false
    end
end

function Wall:collide_end(player,dt)
    player.wall_duck = false
end

return Wall

