local Gamestate = require 'vendor/gamestate'

local Door = {}
Door.__index = Door

function Door.new(node, collider)
    local door = {}
    setmetatable(door, Door)
    door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    door.bb.node = door
    door.player_touched = false
    door.level = node.properties.level
    door.instant  = node.properties.instant
    door.warpin = node.properties.warpin
    door.button = node.properties.button and node.properties.button or 'UP'
    door.to = node.properties.to
    door.height = node.height
    door.width = node.width
    
    --if you can go to a level, passively wait for collision
    --otherwise, it's a oneway ticket
    if door.level then
        collider:setPassive(door.bb)
    else
        collider:setGhost(door.bb)
    end
    return door
end

function Door:switch(player)
    local _, _, _, wy2  = self.bb:bbox()
    local _, _, _, py2 = player.bb:bbox()

    self.player_touched = false
    if math.abs(wy2 - py2) > 10 or player.jumping then
        return
    end

    local level = Gamestate.get(self.level)
    local current = Gamestate.currentState()

    current.collider:setPassive(player.bb)
    if self.level == 'overworld' then
        Gamestate.switch(self.level)
    else
        Gamestate.switch(self.level)
    end
    if self.to ~= nil then
        print( self.to )
        local level = Gamestate.get(self.level)
        assert( level.doors[self.to], "Error! " .. level.name .. " has no door named " .. self.to .. "." )
        local coordinates = {
            x = level.doors[ self.to ].x,
            y = level.doors[ self.to ].y,
        }
        level.player.position = { -- Copy, or player position corrupts entrance data
            x = coordinates.x + self.width / 2 - 24, 
            y = coordinates.y + self.height - 48
        }
        
        if level.doors[self.to].warpin then
            level.player:respawn()
        end
    end

end


function Door:collide(node)
    if not node.isPlayer then return end
    local player = node
    
    if self.instant then
        self:switch(player)
    end
end


function Door:keypressed( button, player)
    if button == self.button and player.kc:active() then
        self:switch(player)
    end
end

return Door


