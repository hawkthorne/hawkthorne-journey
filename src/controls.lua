local gamestate = require 'vendor/gamestate'
local datastore = require 'datastore'

local controls = {}

controls.buttonmap = datastore.get( 'buttonmap', {
    UP = { 'up', 'w', 'kp8' },
    DOWN = { 'down', 's', 'kp2' },
    LEFT = { 'left', 'a', 'kp4' },
    RIGHT = { 'right', 'd', 'kp6' },
    SELECT = { 'return', 'kpenter' },
    START = { 'escape', 'kp-' },
    A = { 'z', 'l', 'lshift', 'rshift', 'kp+' },
    B = { 'x', 'k', ' ', 'kp0' }
} )

controls.keymap = {}
controls.buttonstates = {}
for button, keys in pairs(controls.buttonmap) do
    for _, key in pairs( keys ) do
        controls.keymap[key] = button
    end
    controls.buttonstates[button] = false
end

function controls:keypressed( key )
    local button = self:getButton( key )
    if button then
        gamestate.keypressed( button )
        self.buttonstates[button] = true
    end
end

function controls:keyreleased( key )
    local button = self:getButton( key )
    if button then
        gamestate.keyreleased( button )
        self.buttonstates[button] = false
    end
end

function controls:getButton( key )
    if self.keymap[key] ~= nil then
        return self.keymap[key]
    else
        return false
    end
end

function controls:getState( button )
    return self.buttonstates[button] == true
end

function controls:isDown( button )
    return self.buttonstates[button] == true
end

function controls:isUp( button )
    return self.buttonstates[button] == false
end

return controls
