local gamestate = require 'vendor/gamestate'
local datastore = require 'datastore'

local controls = {}

controls.max_time = 3

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
    controls.buttonstates[button] = { false, -controls.max_time }
end

function controls:keypressed( key )
    local button = self:getButton( key )
    if button then
        gamestate.keypressed( button, -self.buttonstates[button][2] )
        self.buttonstates[button] = { true, 0 }
    end
end

function controls:keyreleased( key )
    local button = self:getButton( key )
    if button then
        gamestate.keyreleased( button, self.buttonstates[button][2] )
        self.buttonstates[button] = { false, 0 }
    end
end

function controls:update( dt )
    for button, state in pairs( controls.buttonstates ) do
        if state[1] then
            self.buttonstates[button][2] = math.min( self.buttonstates[button][2] + dt, self.max_time )
        else
            self.buttonstates[button][2] = math.max( self.buttonstates[button][2] - dt, -self.max_time )
        end
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
    return self.buttonstates[button][1] == true, self.buttonstates[button][2]
end

function controls:isDown( button )
    return self.buttonstates[button][1] == true
end

function controls:isUp( button )
    return self.buttonstates[button][1] == false
end

return controls
