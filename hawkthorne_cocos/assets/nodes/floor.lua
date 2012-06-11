local Floor = {}
Floor.__index = Floor

function Floor.new(node, collider)
    local floor = {}
    setmetatable(floor, Floor)
    floor.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    floor.bb.node = floor
    collider:setPassive(floor.bb)

    return floor
end

function Floor:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, py1, _, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    if player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then
        player.velocity.y = 0
        player.position.y = wy1 - player.height -- fudge factor
        player:moveBoundingBox()

        player.jumping = false
        player.rebounding = false
    end
end

return Floor

