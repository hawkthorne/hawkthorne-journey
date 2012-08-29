local Timer = require 'vendor/timer'

local Platform = {}
Platform.__index = Platform

function Platform.new(node, collider)
    local platform = {}
    setmetatable(platform, Platform)

    platform.node = node

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

        platform.bb = collider:addPolygon( unpack(vertices) )
        -- Stash the polyline on the collider object for future reference
        platform.bb.polyline = polygon
    else
        platform.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        platform.bb.polyline = nil
    end

    platform.bb.node = platform
    collider:setPassive(platform.bb)

    return platform
end

function Platform:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2  = self.bb:bbox()
    local px1, py1, px2, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    function updatePlayer()
        player:moveBoundingBox()
        player.jumping = false
        player.rebounding = false
    end
    
    local _over = false
    local x1,y1,x2,y2 = player.bb:bbox()
    for i,x in pairs( self.node.layer.map.objectLayers.floor.objects ) do
        if ( x1 > x.x + 10 and x1 < x.x + x.width - 10 ) or
           ( x2 > x.x + 10 and x2 < x.x + x.width - 10 ) then
            _over = true
        end
    end
    for i,x in pairs( self.node.layer.map.objectLayers.platform.objects ) do
        if math.floor( player.position.y + player.height ) + 20 < x.y and
            (
                ( x1 > x.x + 10 and x1 < x.x + x.width - 10 ) or
                ( x2 > x.x + 10 and x2 < x.x + x.width - 10 )
            ) then
            _over = true
        end
    end

    if self.bb.polyline
                    and player.velocity.y >= 0
                    -- Prevent the player from being treadmilled through an object
                    and ( self.bb:contains(px2,py2) or self.bb:contains(px1,py2) ) then

        if player.state == 'crouch' and player.velocity.x == 0 and not self.drop and _over then
            if not self.dropdelay then
                self.dropdelay = Timer.add(0.5, function()
                    self.drop = true
                    self.dropdelay = nil
                end)
            end
        else
            if self.dropdelay then
                Timer.cancel(self.dropdelay)
                self.dropdelay = nil
            end
        end
        
        if self.drop then
            Timer.add(0.5, function() self.drop = nil end)
            player.jumping = true
            player.state = 'crouch'
        else
            player.velocity.y = 0
            -- Use the MTV to keep players feet on the ground,
            -- fudge the Y a bit to prevent falling into steep angles
            player.position.y = (py1 - 1) + mtv_y
            updatePlayer()
        end
    elseif player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then

        if player.state == 'crouch' and player.velocity.x == 0 and not self.drop and _over then
            if not self.dropdelay then
                self.dropdelay = Timer.add(0.5, function()
                    self.drop = true
                    self.dropdelay = nil
                end)
            end
        else
            if self.dropdelay then
                Timer.cancel(self.dropdelay)
                self.dropdelay = nil
            end
        end
        
        if self.drop then
            Timer.add(0.5, function() self.drop = nil end)
            player.jumping = true
            player.state = 'crouch'
        else
            player.velocity.y = 0
            player.position.y = wy1 - player.height
            updatePlayer()
        end
    end
end

return Platform
