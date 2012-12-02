local datastore = require 'datastore'

local controls = {}

local buttonmap = datastore.get( 'buttonmap', {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    SELECT = 'v',
    START = 'escape',
    JUMP = ' ',
    ACTION = 'lshift',
} )

local keymap = {}

for button, key in pairs(buttonmap) do
    keymap[key] = button
end

function controls.getButton( key )
    return keymap[key]
end

-- Only use this function for display, it returns 
-- key values that love doesn't use
function controls.getKey( button )
    local key = buttonmap[button]

    if key == " " then
      return "space"
    end

    return key
end

function controls.isDown( button )
    local key = buttonmap[button]

    if key == nil then
        return false
    end

    return love.keyboard.isDown(key)
end

return controls
