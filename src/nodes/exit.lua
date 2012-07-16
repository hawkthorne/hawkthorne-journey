local Gamestate = require 'vendor/gamestate'

local Exit = {}
Exit.__index = Exit

function Exit.new(node, collider)
    local exit = {}
    setmetatable(exit, Exit)
    exit.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    exit.bb.node = exit
    exit.player_touched = false
    collider:setPassive(exit.bb)
    return exit
end

function Exit:switch(player)
    local current = Gamestate.currentState()
    Gamestate.switch('overworld')
end


function Exit:collide(player)
    self:switch(player)
end


return Exit



