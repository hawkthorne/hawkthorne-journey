local store = require 'hawk/store'

local Controls = {}
Controls.__index = Controls

function Controls.new()
    local controls = {}
    setmetatable(controls, Controls)
    
    return controls
end

local db = store.load('controls-1')
local controls = {}

local buttonmap = db:get('buttonmap', {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    SELECT = 'd',
    START = 'escape',
    JUMP = 'x',
    ATTACK = 'c',
    INTERACT = 'v',
})

function Controls:getKeymap()
    local keymap = {}
    for button, key in pairs(buttonmap) do
        keymap[key] = button
    end
    return keymap
end

--local keymap = controls.getKeymap()

function Controls:getButtonmap()
    local t = {}
    for button, _ in pairs(buttonmap) do
        t[button] = self:getKey(button)
    end
    return t
end

function Controls:getButton( key )
    return self:getKeymap()[key]
end

-- Only use this function for display, it returns 
-- key values that love doesn't use
function Controls.getKey( button )
    local key = buttonmap[button]

    if key == " " then
        return "space"
    end

    return key
end

function Controls:isDown( button )
    local key = buttonmap[button]

    if key == nil then
        return false
    end

    return love.keyboard.isDown(key)
end

-- Returns true if key is available to be assigned to a button.
-- Returns false if key is 'f5' or already assigned to a button.
function Controls:keyIsNotInUse(key)
    if key == 'f5' then return false end
    for usedKey, _ in pairs(keymap) do
        if usedKey == key then return false end
    end
    return true
end

-- Reassigns key to button and returns true, or returns false if the key is unavailable.
function Controls:newButton(key, button)
    if self:getButton(key) == button then
        return true
    end

    if self:keyIsNotInUse(key) then
        buttonmap[button] = key
        keymap = self:ggetKeymap()
        db:set('buttonmap', buttonmap)
        db:flush()
        return true
    else
        return false
    end
end

return Controls
