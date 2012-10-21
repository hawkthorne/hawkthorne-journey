local Gamestate = require 'vendor/gamestate'

local Exit = {}
Exit.__index = Exit

function Exit.new(node, collider)
    local exit = {}
    setmetatable(exit, Exit)
    exit.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    exit.bb.node = exit
    exit.door = node.properties.door
    exit.player_touched = false
    collider:setPassive(exit.bb)
    return exit
end

function Exit:switch(player)
    local current = Gamestate.currentState()
    Gamestate.switch('overworld')
end

function Exit:collide(player)
    if self.door then
        return
    end
    self:switch( player )
end

function Exit:keypressed( button, player )
    if self.door and button == 'UP' then
        self:switch( player )
    end
end

return Exit



