local Wall = {}
Wall.__index = Wall

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    wall.node = node
    collider:setPassive(wall.bb)

    return wall
end

function Wall:collide(player, dt, mtv_x, mtv_y)
    if mtv_x ~= 0 then
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
    end        

    if mtv_y > 0 then
        player.velocity.y = 0
        player.position.y = player.position.y + mtv_y
    end
    
    if mtv_y < 0 then
        player.velocity.y = 0
        player.position.y = self.node.y - player.height
        player.jumping = false
    end
end

return Wall

