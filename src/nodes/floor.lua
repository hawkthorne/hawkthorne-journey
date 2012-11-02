local Floor = {}
Floor.__index = Floor
Floor.isFloor = true

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
        floor.bb.polyline = nil
    end

    floor.bb.node = floor
    collider:setPassive(floor.bb)
    floor.isSolid = true
    floor.x = node.x
    floor.y = node.y
    floor.width = node.width
    floor.height = node.height

    return floor
end

function Floor:collide(node, dt, mtv_x, mtv_y)
    if not node.isPlayer then return end
    local player = node

    local _, wy1, _, wy2  = self.bb:bbox()
    local px1, py1, px2, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    function updatePlayer()
        player:moveBoundingBox()
        player.jumping = false
        player.rebounding = false
    end

    if self.bb.polyline
                    and player.velocity.y >= 0
                    -- Prevent the player from being treadmilled through an object
                    and ( self.bb:contains(px2,py2) or self.bb:contains(px1,py2) ) then

        player.velocity.y = 0

        -- Use the MTV to keep players feet on the ground,
        -- fudge the Y a bit to prevent falling into steep angles
        player.position.y = (py1 - 1) + mtv_y
        updatePlayer()
        player:impactDamage()
        player:restore_solid_ground()
        return
    end

    if mtv_x ~= 0 and wy1 + 2 < player.position.y + player.height then
        --prevent horizontal movement
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
        updatePlayer()
    end

    if mtv_y ~= 0 then
        --push back up
        player.velocity.y = 0
        player.position.y = wy1 - player.height
        updatePlayer()
        player:impactDamage()
        player:restore_solid_ground()
    end

end

return Floor
