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
    
    floor.node = node

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
    if node.bb then
        node.bottom_bb = node.bb
    end

    if not (node.floor_pushback or node.wall_pushback) then return end

    if node.velocity.y < 0 and mtv_x == 0 then
      -- don't collide when the player is going upwards above the floor
      -- This happens when enemies hit the player
      return
    end

    local _, wy1, _, wy2  = self.bb:bbox()
    if not node.bottom_bb then print(node.type) end
    local px1, py1, px2, py2 = node.bottom_bb:bbox()
    local distance = math.abs(node.velocity.y * dt) + 0.10

    if self.bb.polyline
                    and node.floor_pushback
                    and node.velocity.y >= 0
                    -- Prevent the player from being treadmilled through an object
                    and ( self.bb:contains(px2,py2) or self.bb:contains(px1,py2) ) then

        -- Use the MTV to keep players feet on the ground,
        -- fudge the Y a bit to prevent falling into steep angles
        node:floor_pushback(self, (py1 - 4) + mtv_y)
        return
    end
    
    if mtv_x ~= 0 
                and node.wall_pushback
                and wy1 + 2 < node.position.y + node.height then
        --prevent horizontal movement
        node:wall_pushback(self, node.position.x + mtv_x)
    end

    if mtv_y < 0 and node.floor_pushback then
        --push back up
        node:floor_pushback(self, wy1 - node.height)
    end

    -- floor doesn't support a ceiling_pushback

end

return Floor
