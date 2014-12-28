local HC = require 'vendor/hardoncollider'

local collider = HC(100, nil, nil)

---
-- Gets the list of filenames in given directory (all *.lua files except init.lua)
-- @return table
--
local function getList(dir)
  local list = {}

  for _, filename in ipairs(love.filesystem.getDirectoryItems(dir)) do
    local indexLua, _ = string.find(filename, ".lua")
    local indexInit, _ = string.find(filename, "init.lua")
    if indexLua > 0 and not indexInit then
      local filename, _ = filename:gsub(".lua", "")
      table.insert(list, filename)
    end
  end

  return list
end

---
-- Loads node of given type
-- @param type string one of the tested/supported types: consumable, material, projectile, throwable or weapon
-- @peram name string
-- @param directory string (optional)
-- @return node
local function loadNode(type, name, directory)
  -- type has to be one of the tested types
  assert(type == 'consumable' or type == 'material' or type == 'projectile' or type == 'throwable' or type == 'weapon')
  assert(name ~= nil and name ~= '')
  local node = {
    name = name,
    type = type,
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    properties = {},
    directory = directory
  }

  local Node = require('nodes/' .. type)
  local ok, msg = pcall(Node.new, node, collider)
  if not ok then
    fail(string.format("Error loading %s '%s' - %s", type, name, msg))
  end
  assert_not_nil(msg, string.format("%s '%s' returned nil", type, name))
  return msg
end

local function checkConsumable(name)
  loadNode('consumable', name)
end

function test_consumables()
  local list = getList('nodes/consumables')
  for _, consumable in ipairs(list) do
    checkConsumable(consumable)
  end
end

local function checkMaterial(name)
  loadNode('material', name)
end

function test_materials()
  local list = getList('nodes/materials')
  for _, material in ipairs(list) do
    checkMaterial(material)
  end
end

local function checkProjectile(name, directory)
  loadNode('projectile', name, directory)
end

function test_projectiles()
  local list = getList('nodes/projectiles')
  for _, projectile in ipairs(list) do
    if projectile == 'lightning' or projectile == 'ghost_pepper' then
      -- lightning is special; this is crude solution, duplicates the directory originally found in "items/misc/lightning.lua"
      checkProjectile(projectile, "scrolls/")
    else
      checkProjectile(projectile)
    end
  end
end

local function checkThrowable(name)
  loadNode('throwable', name)
end

function test_throwables()
  local list = getList('nodes/throwables')
  for _, throwable in ipairs(list) do
    checkThrowable(throwable)
  end
end

local function checkWeapon(name)
  loadNode('weapon', name)
end

function test_weapons()
  local list = getList('nodes/weapons')
  for _, weapon in ipairs(list) do
    checkWeapon(weapon)
  end
end
