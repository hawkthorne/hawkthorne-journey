local store = require 'hawk/store'

local db = store('controls-1')

local InputController = {}
InputController.__index = InputController

local DEFAULT_PRESET = 'actionmap'
local DEFAULT_ACTIONMAP = {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    SELECT = 's',
    START = 'escape',
    JUMP = ' ',
    ATTACK = 'a',
    INTERACT = 'd',
}

local cached = {}
local remapping = false

function InputController.new(name, actionmap)
    local controller = {}
    setmetatable(controller, InputController)

    controller.name = name or DEFAULT_PRESET
    controller:load(actionmap)

    return controller
end

-- Return cached global version if available, create otherwise
-- Unless trying to make a new or custom preset, just use this, not new
function InputController.get(name)
    name = name or DEFAULT_PRESET
    if cached[name] == nil then
        cached[name] = InputController.new(name)
    end
    return cached[name]
end

-- Classmethod to return a preset table from db
function InputController.getPreset(name)
    local mapname = name or DEFAULT_PRESET
    return db:get(mapname, DEFAULT_ACTIONMAP)
end

-- actionmap is optional param; if nil, we load preset with controller name
function InputController:load(actionmap)
    -- Copy to avoid modifying external tables
    local source = actionmap or self.getPreset(self.name)
    self.actionmap = {}
    for k, v in pairs(source) do
        self.actionmap[k] = v
    end
    self:refreshKeymap()
end

-- name is optional override for save name
function InputController:save(name)
    local mapname = name or self.name
    db:set(mapname, self.actionmap)
    db:flush()
end

-- Create inverted version of self.actionmap.
-- actionmap is map[action] == physical_key
-- keymap is map[physical_key] == action
function InputController:refreshKeymap()
    self.keymap = {}
    for action, key in pairs(self.actionmap) do
        self.keymap[key] = action
    end
end

-- Display-sanitized copy of self.actionmap
function InputController:getActionmap()
    local t = {}
    for action, _ in pairs(self.actionmap) do
        t[action] = self:getKey(action)
    end
    return t
end

-- Get action for a given physical key
function InputController:getAction( key )
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

function InputController:enableRemap()
    remapping = true
end

function InputController:disableRemap()
    remapping = false
end

function InputController:isRemapping()
    return remapping
end

-- Returns true if key is available to be assigned to a action.
-- Returns false if key is 'f5' or already assigned to a action.
function InputController:keyIsNotInUse(key)
    if key == 'f5' then return false end
    for usedKey, _ in pairs(self.keymap) do
        if usedKey == key then return false end
    end
    return true
end

-- Reassigns key to action and returns true, or returns false if the key is unavailable.
-- Does not automatically save after modification.
function InputController:newAction(key, action)
    if self:getAction(key) == action then
        return true
    end

    if self:keyIsNotInUse(key) then
        self.actionmap[action] = key
        self:refreshKeymap()
        return true
    else
        return false
    end
end

return InputController
