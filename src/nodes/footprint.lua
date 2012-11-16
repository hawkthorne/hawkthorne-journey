local Footprint = {}
Footprint.__index = Footprint
Footprint.isFootprint = true

---
-- Create a new Player
-- @param collider
-- @return Player
function Footprint.new(collider,plyr)

    local footprint = {}

    setmetatable(footprint, Footprint)

    footprint.collider = collider
    footprint.width = 4
    footprint.height = 4
    footprint.y = plyr.position.y + plyr.height
    footprint.x = plyr.position.x+plyr.width/2-footprint.width/2
    footprint.bb = collider:addRectangle(plyr.position.x+plyr.width/2-footprint.width/2,footprint.y,
                                         footprint.width,footprint.height)
    footprint.bb.node = footprint
    footprint.player = plyr

    return footprint
end

function Footprint:update()
    local player = self.player
    self.x = player.position.x+player.width/2-self.width/2
    self.bb:moveTo(player.position.x + player.width / 2,
                     self.y - (self.height / 2))
end

function Footprint:collide_end(node, dt)
    if node.isPolygonFloorspace then
        --print("==floorspace!!")
    end
end

function Footprint:collide(node, dt, mtv_x, mtv_y)
    if node.isPolygonFloorspace then
        --print("--floorspace!!")
    end
end

return Footprint
    