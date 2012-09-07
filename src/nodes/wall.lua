local Wall = {}
Wall.__index = Wall

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    collider:setPassive(wall.bb)
    wall.isSolid = true

    return wall
end

function Wall:collide(player, dt, mtv_x, mtv_y)
    if mtv_x == 0 then
        return
    end

    player.velocity.x = 0
    player.position.x = player.position.x + mtv_x
end

return Wall

