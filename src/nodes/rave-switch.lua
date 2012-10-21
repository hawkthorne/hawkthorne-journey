local Gamestate = require 'vendor/gamestate'

local RaveSwitch = {}
RaveSwitch.__index = RaveSwitch

function RaveSwitch.new(node, collider)
    local raveswitch = {}
    setmetatable(raveswitch, RaveSwitch)
    raveswitch.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    raveswitch.bb.node = raveswitch
    raveswitch.player_touched = false
    raveswitch.level = node.properties.level
    raveswitch.reenter = node.properties.reenter
    collider:setPassive(raveswitch.bb)
    return raveswitch
end

function RaveSwitch:switch(player)
    local level = Gamestate.get(self.level)
    local current = Gamestate.currentState()

    if not self.reenter and level.new then
        -- create a new level to go into
        Gamestate.load(self.level, level.new(level.name))
        Gamestate.switch(self.level, current.character)
    else
        Gamestate.switch(self.level)
    end
end

function RaveSwitch:keypressed( button, player )
    if button == 'A' then
        self:switch(player)
    end
end

return RaveSwitch
