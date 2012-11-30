local datastore = require 'datastore'

local controls = {}

local buttonmap = datastore.get( 'buttonmap', {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    SELECT = 'v',
    START = 'escape',
    A = 'x',
    B = 'c',
} )

local keymap = {}

for button, key in pairs(buttonmap) do
    keymap[key] = button
end

function controls.getButton( key )
    return keymap[key]
end

function controls.getKey( button )
    return buttonmap[button]
end

function controls.isDown( button )
    local key = buttonmap[button]

    if key == nil then
        return false
    end

    return love.keyboard.isDown(key)
end

return controls
