local tracker = (require 'achievements').new()

local Achievement = {}
Achievement.__index = Achievement

function Achievement.new(node, collider)
    local ach = {}
    setmetatable(ach, Achievement)

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

        ach.bb = collider:addPolygon( unpack(vertices) )
        -- Stash the polyline on the collider object for future reference
        ach.bb.polyline = polygon
    else
        ach.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        ach.bb.polyline = nil
    end

    ach.bb.node = ach
    ach.node = node
    ach.collider = collider
    collider:setPassive(ach.bb)

    ach.alreadyCollided = false

    return ach
end

function Achievement:collide(player, dt, mtv_x, mtv_y)
    if self.alreadyCollided or not player.isPlayer then return end

    local action = self.node.properties.action
    local label  = self.node.properties.label or "unknown event"
    local value  = tonumber(self.node.properties.value) or 1
    if action == 'set' then
        tracker:setCount(label, value)
    elseif action == 'achieve' then
        tracker:achieve(label, value)
    else
        print("unknown action: " .. tostring(action))
    end
end

function Achievement:collide_end(player, dt)
    self.alreadyCollided = false
end

return Achievement
