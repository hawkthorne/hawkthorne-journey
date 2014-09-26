local Consumable = require 'nodes/consumable'
local Material = require 'nodes/material'
local Projectile = require 'nodes/projectile'
local Throwable = require 'nodes/throwable'
local Weapon = require 'nodes/weapon'
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

local function checkConsumable(name)
  local node = {
    name = name,
    type = 'consumable',
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    properties = {}
  }

  local ok, msg = pcall(Consumable.new, node, collider)
  if not ok then
    fail(string.format("Error loading consumable '%s' - %s", name, msg))
  end
  assert_not_nil(msg, string.format("Consumable '%s' returned nil", name))
end

function test_consumables()
  local list = getList('nodes/consumables')
  for _, consumable in ipairs(list) do
    checkConsumable(consumable)
  end
end

local function checkMaterial(name)
  local node = {
    name = name,
    type = 'material',
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    properties = {}
  }

  local ok, msg = pcall(Material.new, node, collider)
  if not ok then
    fail(string.format("Error loading material '%s' - %s", name, msg))
  end
  assert_not_nil(msg, string.format("Material '%s' returned nil", name))
end

function test_materials()
  local list = getList('nodes/materials')
  for _, material in ipairs(list) do
    checkMaterial(material)
  end
end

local function checkProjectile(name, directory)
  local node = {
    name = name,
    type = 'projectile',
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    directory = directory,
    properties = {}
  }

  local ok, msg = pcall(Projectile.new, node, collider)
  if not ok then
    fail(string.format("Error loading projectile '%s' - %s", name, msg))
  end
  assert_not_nil(msg, string.format("Projectile '%s' returned nil", name))
end

function test_projectiles()
  local list = getList('nodes/projectiles')
  for _, projectile in ipairs(list) do
    if projectile == 'lightning' then
      -- lightning is special; this is crude solution, duplicates the directory originally found in "items/misc/lightning.lua"
      checkProjectile(projectile, "scrolls/")
    else
      checkProjectile(projectile)
    end
  end
end

local function checkThrowable(name)
  local node = {
    name = name,
    type = 'throwable',
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    properties = {}
  }

  local ok, msg = pcall(Throwable.new, node, collider)
  if not ok then
    fail(string.format("Error loading throwable '%s' - %s", name, msg))
  end
  assert_not_nil(msg, string.format("Throwable '%s' returned nil", name))
end

function test_throwables()
  local list = getList('nodes/throwables')
  for _, throwable in ipairs(list) do
    checkThrowable(throwable)
  end
end

local function checkWeapon(name)
  local node = {
    name = name,
    type = 'weapon',
    x = 0,
    y = 0,
    width = 24,
    height = 24,
    properties = {}
  }

  local ok, msg = pcall(Weapon.new, node, collider)
  if not ok then
    fail(string.format("Error loading weapon '%s' - %s", name, msg))
  end
  assert_not_nil(msg, string.format("Weapon '%s' returned nil", name))
end

function test_weapons()
  local list = getList('nodes/weapons')
  for _, weapon in ipairs(list) do
    checkWeapon(weapon)
  end
end
