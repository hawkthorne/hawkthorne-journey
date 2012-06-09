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
    door.instant = node.properties.instant
    door.reenter = node.properties.reenter
    collider:setPassive(door.bb)

    return door
end

function Door:switch()
    local level = Gamestate.get(self.level)

    if not self.reenter and level.new then
        -- create a new level to go into
        Gamestate.load(self.level, level.new(level.tmx))
    end

    Gamestate.switch(self.level, level.character)
end


function Door:update(dt, player)
    if self.player_touched and self.instant then
        self:switch()
    end
end


function Door:keypressed(key)
    if key == 'up' or key == 'w' then
        self:switch()
    end
end

return Door


