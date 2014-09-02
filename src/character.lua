local json = require 'hawk/json'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local module = {}

-- Just for backwards compat
module.name = 'abed'

local _loaded_character = nil
local _character = 'abed'
local _costume = 'base'

local Character = {}
Character.__index = Character

function Character:reset()
  self.state = 'idle'
  self.direction = 'right'
end

function Character:sheet()
  return self:getSheet(self.costume)
end

function Character:getSheet(costume)
  local path = 'images/characters/' .. self.name .. '/' .. costume .. '.png'

  if not self.sheets[costume] then
    self.sheets[costume] = love.graphics.newImage(path)
    self.sheets[costume]:setFilter('nearest', 'nearest')
  end

  return self.sheets[costume]
end

function Character:update(dt)
  self:animation():update(dt)
end

function Character:animation()
  return self.animations[self.state][self.direction]
end

function Character:warpUpdate(dt)
  self.animations.warp:update(dt)
end

function Character:respawn()
  self.warpin = true
  self.animations.warp:gotoFrame(1)
  self.animations.warp:resume()
  sound.playSfx( "respawn" )
  Timer.add(0.30, function() self.warpin = false end)
end

function Character:draw(x, y)
  self:animation():draw(self:sheet(), x, y)
end

function Character:getCategory()
  return self.costumemap[self.costume].category
end

function Character:getOverworld()
  return self.costumemap[self.costume].ow
end

function module.pick(name, costume)
  if not love.filesystem.exists("characters/" .. name .. ".json") then
    error("Unknown character " .. name)
  end

  if not love.filesystem.exists("images/characters/" .. name .. "/" .. costume .. ".png") then
    error("Unknown costume " .. costume .. " for character " .. name)
  end

  _character = name
  _costume = costume
  _loaded_character = nil
end

function module.load(character)
  if not love.filesystem.exists("characters/" .. character .. ".json") then
    error("Unknown character " .. character)
  end

  local contents, _ = love.filesystem.read('characters/' .. character .. ".json")
  return json.decode(contents)
end

-- Load the current character. Do all the crazy stuff too
function module.current()
  if _loaded_character then
    return _loaded_character
  end

  local beamPath = 'images/characters/' .. _character .. '/beam.png'
  local basePath = 'images/characters/' .. _character .. '/base.png'
  local characterPath = "characters/" .. _character .. ".json"

  if not love.filesystem.exists(characterPath) then
    error("Unknown character " .. _character)
  end

  local contents, _ = love.filesystem.read('character_map.json')
  local sprite_map = json.decode(contents)

  local contents, _ = love.filesystem.read(characterPath)

  local character = json.decode(contents)
  setmetatable(character, Character)

  character.name = _character
  character.costume = _costume
  character.bbox = character.standing
  character.warpin = false

  if character.animations then --merge
    local base = utils.deepcopy(character.animations)
    character.animations = utils.deepcopy(sprite_map)
    for k,v in pairs(base) do
      character.animations[k] = v
    end
  else
    character.animations = utils.deepcopy(sprite_map)
  end

  -- build the character
  character.beam = love.graphics.newImage(beamPath)
  character.beam:setFilter('nearest', 'nearest')

  character.count = 1

  character.sheets = {}
  character.sheets.base = love.graphics.newImage(basePath)
  character.sheets.base:setFilter('nearest', 'nearest')

  character.mask = love.graphics.newQuad(0, character.offset, 48, 35,
                                         character.sheets.base:getWidth(),
                                         character.sheets.base:getHeight())

  character.positions = utils.require('positions/' .. character.name)

  character._grid = anim8.newGrid(48, 48, 
                                  character.sheets.base:getWidth(),
                                  character.sheets.base:getHeight())

  character._warp = anim8.newGrid(36, 300, character.beam:getWidth(), character.beam:getHeight())

  for state, _ in pairs(character.animations) do
    local data = character.animations[state]
    if state == 'warp' then
      character.animations[state] = anim8.newAnimation(data[1], character._warp(unpack(data[2])), data[3])
    else
      if type( data[1] ) == 'string' then
        -- positionless
        character.animations[state] = anim8.newAnimation(data[1], character._grid(unpack(data[2])), data[3])
      else
        -- positioned
        for i, _ in pairs( data ) do
          character.animations[state][i] = anim8.newAnimation(data[i][1], character._grid(unpack(data[i][2])), data[i][3])
        end
      end
    end
  end

  character.costumemap = {}
  character.categorytocostumes = {}

  for _,c in pairs(character.costumes) do
    character.costumemap[c.sheet] = c
    character.categorytocostumes[c.category] = character.categorytocostumes[c.category] or {}
    table.insert(character.categorytocostumes[c.category], c)
  end

  _loaded_character = character
  return character
end


function module.getCostumeImage(character, costume)
  local path = "images/characters/" .. character .. "/" .. costume .. ".png"
  return love.graphics.newImage(path)
end


function module.characters()
  local list = {}

  for _, filename in pairs(love.filesystem.getDirectoryItems('characters')) do
    local name, _ = filename:gsub(".json", "")
    table.insert(list, name)
  end

  return list
end

--returns the requested character's costume that is most similar to the current character
function module.findRelatedCostume(name, category)
  local char = module.load(name)

  for _, costume in pairs(char.costumes) do
    if costume.category == category then
      return costume.sheet
    end
  end

  return 'base'
end


return module
