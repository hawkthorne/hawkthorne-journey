local controls = require("inputcontroller").get()
local Level = require "level"
local Sound = require 'vendor/TEsound'
local utils = require "utils"

local TS = {}

-- all loaded levels
local levels = nil

---
-- Adds key-value pair into the supplied table
-- @param t associative array with multiple values
-- @param key
-- @param value
-- @return nil
local function addItem(t, key, value)
  assert(type(t) == "table" and key ~= nil and value ~= nil)
  if t[key] == nil then
    t[key] = { value }
  elseif not utils.contains(t[key], value) then
    table.insert(t[key], value)
  end
end

---
-- Gets user-friendly identifier of all items in the supplied table
-- @param t table
-- @return string
local function getSourceIds(t)
  assert(type(t) == "table")
  local ids = {}
  for _,item in pairs(t) do
    table.insert(ids, item:getSourceId())
  end
  return table.concat(ids, "; ")
end

---
-- Loads all levels reachable from 'studyroom' into {@link levels}
-- @return nil
local function loadLevels()
  if levels then return end

  levels = {}

  ---
  -- Loads target level, with improved error message in case of an error
  -- @param todoItem
  -- @return Level
  local function getLevel(todoItem)
    assert(todoItem ~= nil and type(todoItem.toLevel) == "string")
    local ok, msg = pcall(Level.new, todoItem.toLevel)
    if not ok then
      local levelRef = (todoItem.fromDoor ~= nil) and todoItem.fromDoor:getSourceId() or ("level " .. todoItem.fromLevel)
      error(string.format("Error loading level '%s' (referenced from %s) - %s", todoItem.toLevel, levelRef, msg))
      return nil
    else
      return msg
    end
  end

  ---
  -- Adds item into the table
  -- @param t table
  -- @item
  -- @return nil
  local function addTodoItem(t, item)
    assert(type(t) == "table" and item ~= nil and item.toLevel ~= nil and item.fromLevel ~= nil)
    table.insert(t, item)
  end

  ---
  -- Removes first item in the table and returns it
  -- @param t table
  -- @return todoItem
  local function removeTodoItem(t)
    assert(type(t) == "table" and #t > 0)
    local item = table.remove(t, 1)
    return item
  end

  -- comparator function for determining if supplied todoItems refer to the same level
  local compTodoLevel = function (item1, item2)
    assert(item1 ~= nil and item2 ~= nil)
    return item1.toLevel == item2.toLevel
  end

  -- queue of levels waiting for processing
  -- each item is table:
  --   item.toLevel string - name of the target level [required]
  --   item.fromLevel string - name of the source level (for reporting purposes in case of errors) [required]
  --   item.fromDoor Door - door in the source level (for reporting purposes in case of errors) [optional]
  local levelNamesTodo = {}
  addTodoItem(levelNamesTodo, {toLevel="studyroom", fromLevel="(default)"})

  while #levelNamesTodo > 0 do
    local levelTodo = removeTodoItem(levelNamesTodo)
    local levelName = levelTodo.toLevel

    -- overworld is special, can't be processed like common level
    if levelName ~= "overworld" then
      local level = getLevel(levelTodo)
      -- loading all levels requires quite a lot of memory
      -- map field is currently not needed for testing, set it to nil to free its memory
      level.map = nil

      local doors = level:getOutgoingDoors()
      -- skip levels already reached
      for _,door in ipairs(doors) do
        local targetLevelname = door.level
        if targetLevelname ~= levelName and levels[targetLevelname] == nil and not utils.containsComp(levelNamesTodo, {toLevel=targetLevelname}, compTodoLevel) then
          addTodoItem(levelNamesTodo, {toLevel=targetLevelname, fromLevel=levelName, fromDoor=door})
        else
        end
      end

      levels[levelName] = level
    else
      --local levelRef = (levelTodo.fromDoor ~= nil) and levelTodo.fromDoor:getSourceId() or ("level " .. levelTodo.fromLevel)
      --print(string.format("Warning: Door pointing to overworld - %s", levelRef))
    end
  end
end

---
-- Test suite setup
function TS.suite_setup()
  loadLevels()
  assert(utils.propcount(levels) > 0, "No levels loaded")
end

function TS.suite_teardown()
  levels = nil
end

---
-- Checks supplied door
-- - target level and door has to exist (or be empty)
-- - button has to be recognized by inputcontroller
-- - sound has to be false/true or name of valid sound
-- - key has to be loadable key; can't test if key is also placed somewhere in the world, because some keys are loaded dynamically (e.g. white_crystal)
--     instant doors cannot require a key
-- @param door Door
-- @param sounds associative array with multiple values - collected sounds from doors for later testing
-- @return nil
local function checkDoor(door, sounds)
  if door.level ~= nil then
    local targetLevelName = door.level
    if targetLevelName == "overworld" then
      -- skip check
    else
      local targetLevel = levels[targetLevelName]
      assert_not_nil(targetLevel, string.format("Level %s not found. Referenced from %s.", targetLevelName, door:getSourceId()))
      local targetDoorName = door.to
      if targetDoorName == nil then
        -- allow doors with no target door names into other level and assume 'main'
        if door.containerLevel ~= nil and door.containerLevel.name ~= targetLevelName then
          --print(string.format("Warning: Target door name is unspecified - %s.", door:getSourceId()))
          targetDoorName = "main"
        else
          fail(string.format("Target door name into the same level is unspecified - %s.", door:getSourceId()))
        end
      end
      assert_true(targetDoorName ~= "", string.format("Target door name is empty - %s.", door:getSourceId()))
      local targetDoor = targetLevel.doors[targetDoorName]
      assert_not_nil(targetDoor, string.format("Door '%s' not found in level %s. Referenced from %s.", targetDoorName, targetLevelName, door:getSourceId()))
    end
  end

  do
    local actionmap = controls:getActionmap()
    local button = door.button
    assert_not_nil(actionmap[button], string.format("Value '%s' of door's property button not recognized (%s).", tostring(button), door:getSourceId()))
  end

  if type(door.sound) ~= 'boolean' then
    addItem(sounds, door.sound, door)
  end

  if door.key ~= nil then
    local keyName = door.key
    local ok, msg = pcall(utils.require, 'items/keys/' .. keyName)

    if not ok then
      fail(string.format("Error loading key '%s'. Referenced from %s - %s.", keyName, door:getSourceId(), msg))
    end
    assert_not_nil(msg, string.format("Key '%s' not found. Referenced from %s.", keyName, door:getSourceId()))

    if door.instant then
      fail(string.format("Key (%s) not allowed for instant door - %s.", keyName, door:getSourceId()))
    end
  end
end

---
-- Tests referential integrity of doors of all levels
function TS.test_doors()
  -- collected doors' sound properties (associative array with multiple values)
  -- don't test sounds for each door, multiple doors can use the same sound
  --   in case of error it provides better information
  local sounds = {}

  for levelname,level in pairs(levels) do
    for _,door in pairs(level.nodes) do
      if door.isDoor then
        checkDoor(door, sounds)
      end
    end

    -- level has to contain door 'main'
    local mainDoor = level.doors['main']
    assert_not_nil(mainDoor, string.format("Door 'main' not found in %s.", level:getSourceId()))
  end

  local oldSoundDisabled = Sound.disabled
  Sound.disabled = false
  -- check collected sounds
  for sound,nodes in pairs(sounds) do
    local ok, msg = pcall(Sound.playSfx, sound)
    if not ok then
      local ids = getSourceIds(nodes)
      fail(string.format("Error playing sound '%s' (referenced from doors: %s) - %s", sound, ids, msg))
    end
  end
  Sound.disabled = oldSoundDisabled
end

---
-- Tests playability of musics of all levels
function TS.test_music()
  -- collected levels' musics
  -- don't test music for each level, multiple levels can use the same music
  local musics = {}
  for levelname,level in pairs(levels) do
    addItem(musics, level.music, level)
  end

  local oldSoundDisabled = Sound.disabled
  Sound.disabled = false
  -- check collected musics
  for music,levels in pairs(musics) do
    local ok, msg = pcall(Sound.playMusic, music)
    if not ok then
      local ids = getSourceIds(levels)
      fail(string.format("Error playing music '%s' (referenced from levels: %s) - %s", music, ids, msg))
    end
  end
  Sound.stopMusic()
  Sound.disabled = oldSoundDisabled
end

---
-- Checks supplied breakable_block
-- - sound (if set) has to be name of valid sound
-- @param block Wall
-- @param sounds associative array with multiple values - collected sounds from blocks for later testing
-- @return nil
local function checkBreakableBlock(wall, sounds)
  if wall.sound then
    addItem(sounds, wall.sound, wall)
  end
end

---
-- Tests breakable_blocks (walls)
function TS.test_breakable_blocks()
  -- collected breakable_blocks' sound properties (associative array with multiple values)
  -- don't test sounds for each breakable_block, multiple breakable_blocks can use the same sound
  --   in case of error it provides better information
  local sounds = {}

  for levelname,level in pairs(levels) do
    for _,wall in pairs(level.nodes) do
      if wall.isWall then
        checkBreakableBlock(wall, sounds)
      end
    end
  end

  local oldSoundDisabled = Sound.disabled
  Sound.disabled = false
  -- check collected sounds
  for sound,nodes in pairs(sounds) do
    local ok, msg = pcall(Sound.playSfx, sound)
    if not ok then
      local ids = getSourceIds(nodes)
      fail(string.format("Error playing sound '%s' (referenced from breakable_blocks: %s) - %s", sound, ids, msg))
    end
  end
  Sound.disabled = oldSoundDisabled
end

return TS
