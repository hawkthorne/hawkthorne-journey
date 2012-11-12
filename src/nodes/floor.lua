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
        floor.bb.polyline = nil
    end

    floor.bb.node = floor
    collider:setPassive(floor.bb)
    floor.isSolid = true

    return floor
end

function Floor:collide(node, dt, mtv_x, mtv_y)
    if not (node.wall_collide_floor or node.wall_collide_side) then return end
    local player = node

    local _, wy1, _, wy2  = self.bb:bbox()
    local px1, py1, px2, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    if self.bb.polyline
                    and player.wall_collide_floor
                    and player.velocity.y >= 0
                    -- Prevent the player from being treadmilled through an object
                    and ( self.bb:contains(px2,py2) or self.bb:contains(px1,py2) ) then

        -- Use the MTV to keep players feet on the ground,
        -- fudge the Y a bit to prevent falling into steep angles
        player:wall_collide_floor(self, (py1 - 4) + mtv_y)
        if player.impactDamage then
            player:impactDamage()
        end
        return
    end

    if mtv_x ~= 0 
                and player.wall_collide_side
                and wy1 + 2 < player.position.y + player.height then
        --prevent horizontal movement
        player:wall_collide_side(self, player.position.x+mtv_x)
    end

    if mtv_y ~= 0 and player.wall_collide_floor then
        --push back up
        player:wall_collide_floor(self, wy1 - player.height)
        if player.impactDamage then
            player:impactDamage()
        end
    end

end

return Floor
