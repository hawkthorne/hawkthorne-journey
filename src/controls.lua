local datastore = require 'datastore'

local controls = {}

local buttonmap = datastore.get( 'buttonmap', {
    UP = { 'up', 'w', 'kp8' },
    DOWN = { 'down', 's', 'kp2' },
    LEFT = { 'left', 'a', 'kp4' },
    RIGHT = { 'right', 'd', 'kp6' },
    SELECT = { 'return', 'kpenter' },
    START = { 'escape', 'kp-' },
    A = { 'z', 'l', 'lshift', 'rshift', 'kp+' },
    B = { 'x', 'k', ' ', 'kp0' }
} )

local keymap = {}

for button, keys in pairs(buttonmap) do
    for _, key in pairs( keys ) do
        keymap[key] = button
    end
end

function controls.getButton( key )
    return keymap[key]
end


function controls.isDown( button )
    local keys = buttonmap[button]

    if keys == nil then
        return false
    end

    for _, key in ipairs(keys) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

return controls