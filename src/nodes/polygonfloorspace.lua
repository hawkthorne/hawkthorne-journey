local controls = require 'controls'
    
local PolygonFloorspace = {}
PolygonFloorspace.__index = PolygonFloorspace
PolygonFloorspace.isPolygonFloorspace = true
PolygonFloorspace.isSolid = true

function PolygonFloorspace.new(node, collider)
    local polyfloor = {}
    setmetatable(polyfloor, PolygonFloorspace)

    --If the node is a polyline, we need to draw a polygon rather than rectangle
    local polygon = node.polygon
    local vertices = {}

    for i, point in ipairs(polygon) do
        print(i)
        table.insert(vertices, node.x + point.x)
        table.insert(vertices, node.y + point.y)
        print(node.x + point.x)
        print(node.y + point.y)
        print()
    end

        polyfloor.bb = collider:addPolygon(unpack(vertices))
    --polyfloor.bb.polyline = polygon
    polyfloor.bb.node = polyfloor
    polyfloor.vertices = vertices
    polyfloor.collider = collider

    collider:setPassive(polyfloor.bb)
    return polyfloor
end

function PolygonFloorspace:update(dt, player)

    if player.outofbounds then
        player.position = {x = player.last.x,
                           y = player.last.y}
        player:moveBoundingBox()
    end
end

function PolygonFloorspace:draw()
end

function PolygonFloorspace:collide_end(node, dt)
    local player
    if node.isFootprint then 
        print("==footprint")
        local footprint = node
        player = footprint.player
    else
        return
    end

    -- if not node.isPlayer then return end
    -- local player = node
    
    player.position = {x = player.last.x,
                       y = player.last.y}

    player:moveBoundingBox()
    player.outofbounds = true
end


function PolygonFloorspace:collide(node, dt, mtv_x, mtv_y)
    local player
    if node.isFootprint then 
        print("--footprint")
        local footprint = node
        player = footprint.player
    else
        return
    end
    
    player:moveBoundingBox()
    
   player.last = {}
    player.last.x = player.position.x
    player.last.y = player.position.y

    player.outofbounds = false
end

return PolygonFloorspace
