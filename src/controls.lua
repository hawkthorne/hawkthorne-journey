local store = require 'hawk/store'

local db = store('controls-1')

local InputController = {}
InputController.__index = InputController

function InputController.new(buttonmap)
    local controller = {}
    setmetatable(controller, InputController)

    controller.buttonmap = buttonmap or InputController.getButtonMap()
    controller:refreshKeymap()

    return controller
end

function InputController.getButtonMap(name)
    -- Classmethod to return a preset table from db
    local mapname = name or 'buttonmap'
    return db:get(mapname, {
        UP = 'up',
        DOWN = 'down',
        LEFT = 'left',
        RIGHT = 'right',
        SELECT = 's',
        START = 'escape',
        JUMP = ' ',
        ATTACK = 'a',
        INTERACT = 'd',
    })
end

function InputController:refreshKeymap()
    -- Create inverted version of self.buttonmap.
    -- buttonmap is map[action] == physical_key
    -- keymap is map[physical_key] == action
    self.keymap = {}
    for button, key in pairs(self.buttonmap) do
        self.keymap[key] = button
    end
end

function InputController:getButtonmap()
    -- Display-sanitized copy of self.buttonmap
    local t = {}
    for button, _ in pairs(self.buttonmap) do
        t[button] = self:getKey(button)
    end
    return t
end

function InputController:getButton( key )
    -- Get action for a given physical key
    return self.keymap[key]
end

-- Only use this function for display, it returns 
-- key values that love doesn't use
function InputController:getKey( button )
    local key = self.buttonmap[button]

    if key == " " then
        return "space"
    end

    return key
end

function InputController:isDown( button )
    local key = self.buttonmap[button]

    if key == nil then
        return false
    end

    return love.keyboard.isDown(key)
end

-- Returns true if key is available to be assigned to a button.
-- Returns false if key is 'f5' or already assigned to a button.
function InputController:keyIsNotInUse(key)
    if key == 'f5' then return false end
    for usedKey, _ in pairs(keymap) do
        if usedKey == key then return false end
    end
    return true
end

-- Reassigns key to button and returns true, or returns false if the key is unavailable.
function InputController:newButton(key, button)
    if self:getButton(key) == button then
        return true
    end

    if self:keyIsNotInUse(key) then
        buttonmap[button] = key
        keymap = self:getKeymap()
        db:set('buttonmap', buttonmap)
        db:flush()
        return true
    else
        return false
    end
end

return InputController
