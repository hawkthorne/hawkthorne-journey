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
        table.insert(vertices, node.x + point.x)
        table.insert(vertices, node.y + point.y)
    end

    polyfloor.bb = collider:addPolygon(unpack(vertices))
    polyfloor.bb.node = polyfloor
    polyfloor.vertices = vertices
    polyfloor.collider = collider

    collider:setPassive(polyfloor.bb)
    return polyfloor
end

function PolygonFloorspace:update(dt, owner)
end

function PolygonFloorspace:draw()
end

function PolygonFloorspace:collide_end(node, dt)
    if not node.isFootprint then return end

    local footprint = node
    local owner = footprint.owner

    owner.velocity.x = 0 -- -owner.velocity.x
    owner.velocity.y = 0 -- -owner.velocity.y
    node.x = node.last_x
    node.y = node.last_y
    owner.outofbounds = true
    
end


function PolygonFloorspace:collide(node, dt, mtv_x, mtv_y)
    if not node.isFootprint then return end

    local footprint = node
    local owner = footprint.owner
    
    node.last_x = node.x
    node.last_y = node.y
    node.parent_x = owner.position.x
    node.parent_y = owner.position.y

    owner.outofbounds = false
end

return PolygonFloorspace
