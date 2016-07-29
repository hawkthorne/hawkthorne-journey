local store = require 'hawk/store'
local utils = require "utils"

local db = store('controls-1')

local InputController = {}
InputController.__index = InputController

local DEFAULT_PRESET = 'actionmap'
local DEFAULT_ACTIONMAP = {
  actionmap = {
    UP = 'up',
    DOWN = 'down',
    LEFT = 'left',
    RIGHT = 'right',
    SELECT = 's',
    START = 'escape',
    JUMP = 'space',
    ATTACK = 'a',
    INTERACT = 'd',
  },
  gamepad = {
    UP = 'dpup',
    DOWN = 'dpdown',
    LEFT = 'dpleft',
    RIGHT = 'dpright',
    SELECT = 'back',
    START = 'start',
    JUMP = 'a',
    ATTACK = 'x',
    INTERACT = 'y',
  },
  joystick = {
    UP = 'dpup',
    DOWN = 'dpdown',
    LEFT = 'dpleft',
    RIGHT = 'dpright',
    SELECT = '1',
    START = '4',
    JUMP = '2',
    ATTACK = '8',
    INTERACT = '6',
  }
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

function InputController:switch(joystick)
  local controller_name = "actionmap"
  if joystick and joystick:isGamepad() then
    controller_name = joystick:getName() or "gamepad"
  elseif joystick and not joystick:isGamepad() then
    controller_name = joystick:getName() or "joystick"
  end
  if remapping then return end
  if self.name ~= controller_name then
    self.name = controller_name
    if controller_name ~= "actionmap" then
      self.joystick = joystick
    else
      self.joystick = nil
    end
    self:load(self.name)
  end
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
function InputController:getPreset(name)
  local function defaultMap(name)
    if not DEFAULT_ACTIONMAP[name] then
      if self.joystick and self.joystick:isGamepad() then
        return DEFAULT_ACTIONMAP["gamepad"]
      elseif self.joystick and not self.joystick:isGamepad() then
        return DEFAULT_ACTIONMAP["joystick"]
      else
        return DEFAULT_ACTIONMAP["actionmap"]
      end
    end

    return DEFAULT_ACTIONMAP[name]
  end

  local mapname = name or DEFAULT_PRESET
  return db:get(mapname, defaultMap(name))
end

-- actionmap is optional param; if nil, we load preset with controller name
function InputController:load(actionmap)
  -- Copy to avoid modifying external tables
  if type(actionmap) ~= "table" then actionmap = nil end
  local source = actionmap or self:getPreset(self.name)
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
  if key == "return" then return "JUMP" end
  if key == "escape" then return "START" end
  return self.keymap[key]
end

-- Only use this function for display, it returns 
-- key values that love doesn't use
function InputController:getKey( action )
  local key = self.actionmap[action]

  if key == " " then return "space" end

  return key
end

function InputController:isDown( action )
  local key = self.actionmap[action]

  if key == nil then
    return false
  end

  if self.joystick then
    if self.joystick:isGamepad() then
      return self.joystick:isGamepadDown(key)
    else
      axisDir1, axisDir2, _ = self.joystick:getAxes()
      if axisDir1 < 0 then
        if action == "LEFT" then return true end
      end
      if axisDir1 > 0 then
        if action == "RIGHT" then return true end
      end
      if axisDir2 < 0 then
        if action == "UP" then return true end
      end
      if axisDir2 > 0 then
        if action == "DOWN" then return true end
      end
      if type(tonumber(key)) ~= "number" then return false end
      return self.joystick:isDown(tonumber(key))
    end
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
  if key == "return" and action ~= "JUMP" or
     key == "escape" and action ~= "START" then
    return false
  end
  if self:getAction(key) == action then
    self.actionmap[action] = key
    self:refreshKeymap()
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