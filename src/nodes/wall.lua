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
    player.wall_collision = true
    if player.state == player.crouch_state and mtv_y < player.bbox_height / 2 then
        return
    end

    if mtv_x ~= 0 then
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
    end
    
    if mtv_y > player.bbox_height / 2 - 5 then
        --player standing up from crouch
        player.state = player.crouch_state
        player.position.x = player.position.x + ( 5 * ( player.direction == 'right' and 1 or -1 ) )
        return
    end

    if mtv_y > 0 and mtv_y < player.bbox_height / 2 - 5 then
        player.velocity.y = 0
        player.position.y = player.position.y + mtv_y
    end
    
    if mtv_y < 0 then
        player.velocity.y = 0
        player.position.y = self.node.y - player.height
        player.jumping = false
    end
end

function Wall:collide_end(player,dt)
    player.wall_collision = false
end

return Wall

