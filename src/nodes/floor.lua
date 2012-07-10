local Floor = {}
Floor.__index = Floor

function Floor.new(node, collider)
    local floor = {}
    setmetatable(floor, Floor)

    --If the node is a polyline, we need to draw a polygon rather than rectangle
    if node.polyline or node.polygon then
        local polygon = node.polyline or node.polygon
        local vertices = {}

        for k,vertex in ipairs(polygon) do
            -- Determine whether this is an X or Y coordinate
            if k % 2 == 0 then
                table.insert(vertices, vertex + node.y)
            else
                table.insert(vertices, vertex + node.x)
            end
        end

        floor.bb = collider:addPolygon( unpack(vertices) )
        -- Stash the polyline on the collider object for future reference
        floor.bb.polyline = polygon
    else
        floor.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        floor.bb.polyline = false
    end

    floor.bb.node = floor
    collider:setPassive(floor.bb)

    return floor
end

function Floor:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, py1, _, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    if self.bb.polyline and player.velocity.y >= 0 and mtv_y < 0 then
        player.velocity.y = 0
        -- Use the MTV to keep players feet on the ground,
        -- fudge the Y a bit to prevent falling into steep angles
        player.position.y = (py1 - 2) + mtv_y
    elseif not self.bb.polyline and player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then
        player.velocity.y = 0
        player.position.y = wy1 - player.height -- fudge factor
    end

    player:moveBoundingBox()

    player.jumping = false
    player.rebounding = false

end

return Floor

