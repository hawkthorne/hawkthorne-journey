local store = require 'hawk/store'

local db = store('controls-1')

local InputController = {}
InputController.__index = InputController

function InputController.new(actionmap)
    local controller = {}
    setmetatable(controller, InputController)

    controller.actionmap = actionmap or InputController.getActionMap()
    controller:refreshKeymap()

    return controller
end

function InputController.getActionMap(name)
    -- Classmethod to return a preset table from db
    local mapname = name or 'actionmap'
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
    -- Create inverted version of self.actionmap.
    -- actionmap is map[action] == physical_key
    -- keymap is map[physical_key] == action
    self.keymap = {}
    for action, key in pairs(self.actionmap) do
        self.keymap[key] = action
    end
end

function InputController:getActionmap()
    -- Display-sanitized copy of self.actionmap
    local t = {}
    for action, _ in pairs(self.actionmap) do
        t[action] = self:getKey(action)
    end
    return t
end

function InputController:getAction( key )
    -- Get action for a given physical key
    return self.keymap[key]
end

-- Only use this function for display, it returns 
-- key values that love doesn't use
function InputController:getKey( action )
    local key = self.actionmap[action]

    if key == " " then
        return "space"
    end

    return key
end

function InputController:isDown( action )
    local key = self.actionmap[action]

    if key == nil then
        return false
    end

    return love.keyboard.isDown(key)
end

-- Returns true if key is available to be assigned to a action.
-- Returns false if key is 'f5' or already assigned to a action.
function InputController:keyIsNotInUse(key)
    if key == 'f5' then return false end
    for usedKey, _ in pairs(keymap) do
        if usedKey == key then return false end
    end
    return true
end

-- Reassigns key to action and returns true, or returns false if the key is unavailable.
function InputController:newAction(key, action)
    if self:getAction(key) == action then
        return true
    end

    if self:keyIsNotInUse(key) then
        actionmap[action] = key
        keymap = self:getKeymap()
        db:set('actionmap', actionmap)
        db:flush()
        return true
    else
        return false
    end
end

return InputController
