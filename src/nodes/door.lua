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
    door.reenter  = node.properties.reenter
    door.entrance = node.properties.entrance
    collider:setPassive(door.bb)

    return door
end

function Door:switch(player)
    local _, _, _, wy2  = self.bb:bbox()
    local _, _, _, py2 = player.bb:bbox()
    
    if player.currently_held and player.currently_held.unuse then
        player.currently_held:unuse('sound_off')
    end

    self.player_touched = false
    if math.abs(wy2 - py2) > 10 or player.jumping then
        return
    end

    local level = Gamestate.get(self.level)
    local current = Gamestate.currentState()

    current.default_position = player.position
    current.collider:setGhost(player.bb)
    if not self.reenter and level.new then
        -- create a new level to go into
        Gamestate.load(self.level, level.new(level.name))
        Gamestate.switch(self.level, current.character)
    else
        Gamestate.switch(self.level)
    end
    if self.entrance ~= nil then
        local level = Gamestate.get(self.level)
        local coordinates = level.entrances[self.entrance]
        level.player.position = {x=coordinates.x, y=coordinates.y} -- Copy, or player position corrupts entrance data
    end
end


function Door:collide(node)
    if node.isPlayer and self.instant then
        self:switch(node)
    end
end


function Door:keypressed( button, player)
    if button == 'UP' and player.kc:active() then
        self:switch(player)
    end
end

return Door


