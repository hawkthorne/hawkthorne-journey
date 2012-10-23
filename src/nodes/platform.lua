local Timer = require 'vendor/timer'
local controls = require 'controls'

local Platform = {}
Platform.__index = Platform

function Platform.new(node, collider)
    local platform = {}
    setmetatable(platform, Platform)

    --If the node is a polyline, we need to draw a polygon rather than rectangle
    if node.polyline or node.polygon then
        local polygon = node.polyline or node.polygon
        local vertices = {}

        for i, point in ipairs(polygon) do
            table.insert(vertices, node.x + point.x)
            table.insert(vertices, node.y + point.y)
        end
           
        platform.bb = collider:addPolygon(unpack(vertices))
        platform.bb.polyline = polygon
    else
        platform.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        platform.bb.polyline = nil
    end
    
    platform.drop = node.properties.drop ~= 'false'

    platform.bb.node = platform
    collider:setPassive(platform.bb)

    return platform
end

function Platform:collide( player, dt, mtv_x, mtv_y )
    self.player_touched = true
    
    if self.dropping then
        return
    end
    
    local _, wy1, _, wy2  = self.bb:bbox()
    local px1, py1, px2, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    function updatePlayer()
        player:moveBoundingBox()
        player.jumping = false
        player.rebounding = false
        player:impactDamage()
    end

    if self.bb.polyline
                    and player.velocity.y >= 0
                    -- Prevent the player from being treadmilled through an object
                    and ( self.bb:contains(px2,py2) or self.bb:contains(px1,py2) ) then
        
        player.velocity.y = 0
        -- Use the MTV to keep players feet on the ground,
        -- fudge the Y a bit to prevent falling into steep angles
        player.position.y = (py1 - 4 ) + mtv_y
        updatePlayer()
    elseif player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then
        
        player.velocity.y = 0
        player.position.y = wy1 - player.height
        updatePlayer()
    end
end

function Platform:collide_end()
    self.player_touched = false
    self.dropping = false
    if self.timer then
        Timer.cancel(self.timer)
    end
end

function Platform:keyreleased( button, player )
    if button == 'DOWN' and self.timer then
        Timer.cancel(self.timer)
    end
end

function Platform:keypressed( button, player )
    if button == 'DOWN' and self.drop then
        self.timer = Timer.add( 0.35, function() self.dropping = true end )
    end
end

return Platform
