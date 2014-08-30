local app = require 'app'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local Fire = require 'nodes/fire'

local gamesave = app.gamesaves:active()

local Building = {}

Building.__index = Building

function Building.new(node, collider, level)
  local building = {}
  setmetatable(building, Building)

  building.image = love.graphics.newImage('images/buildings/' .. level.name .. '/' .. node.name .. '.png')
  building.burnt_image = love.graphics.newImage('images/buildings/' .. level.name .. '/' .. node.name .. '_burned.png')
  building.image:setFilter('nearest', 'nearest')
  building.burnt_image:setFilter('nearest', 'nearest')


  building.name = node.name
  building.x = node.x
  building.y = node.y
  building.width = node.width
  building.height = node.height

  building.state = 'default'

  building.tiles = {}

  building.tilewidth = level.map.tilewidth
  building.tileheight = level.map.tileheight
  building.tileColumns = node.width / building.tilewidth
  building.tileRows = node.height / building.tileheight

  for y=0,(building.tileRows - 1) do
    for x=0,(building.tileColumns - 1) do
      local index = y * building.tileColumns + x
      local offsetY = y * building.tileheight
      local offsetX = x * building.tilewidth

      building.tiles[index] = { state = 'default',
                                x = building.x + offsetX,
                                y = building.y + offsetY,
                                quad = love.graphics.newQuad(offsetX, offsetY,
                                        building.tilewidth, building.tileheight,
                                        building.image:getDimensions()) }
    end
  end

  return building
end

function Building:enter()
  -- Store all of the platforms and doors that are inside the building node
  local level = self.containerLevel

  self.platforms = {}
  for k,platform in pairs(level.nodes) do
    if platform.isPlatform and (platform.node.x >= self.x and platform.node.x <= self.x + self.width)
      and (platform.node.y >= self.y and platform.node.y <= self.y + self.height) then
      table.insert(self.platforms, platform)
    end
  end

  self.doors = {}
  for k,door in pairs(level.nodes) do
    if door.isDoor and (door.node.x >= self.x and door.node.x <= self.x + self.width)
      and (door.node.y >= self.y and door.node.y <= self.y + self.height) then
      table.insert(self.doors, door)
    end
  end

  if gamesave:get(self.name .. '_building_burned', false) then
    self.state = 'burned'
    self:burned()
  end
  if gamesave:get(self.name .. '-dead', false) and gamesave:get(self.name .. '_building_burned', false) == false then
    self.state = 'burning'
    self:burn()
  end
end

function Building:burned()
  gamesave:set(self.name .. '_building_burned', true)

  local level = self.containerLevel

  -- Remove all doors within the building node
  for k,door in pairs(self.doors) do
    level:removeNode(door)
  end

  -- Remove all platforms within the building node
  for k,platform in pairs(self.platforms) do
    level:removeNode(platform)
  end
end

function Building:burn()
  if self.state == 'burning' then
    self:burn_row(1)
  end

  self:burned()
end

function Building:burn_row(row)
  local column = {}
  for i=0, self.tileColumns do
    column[i] = i
  end
  column = utils.shuffle(column)

  for i=1, #column do
    local tile = self.tiles[(row * self.tileColumns - self.tileColumns) + (column[i] - 1)]
    if tile.state ~= 'burned' and tile.state ~= 'burning' then
      Timer.add(math.random(0.5,0.75), function()
        self:burn_tile(tile)
      end)
    end
  end

  if row < self.tileRows then
    Timer.add(math.random(1,1.5), function()
      self:burn_row(row + 1)
    end)
  end
end

function Building:burn_tile(tile)
  tile.state = 'burning'

  local level = self.containerLevel

  for i=1,math.random(2,3) do
    local fire = Fire.new(tile)
    level:addNode(fire)

    Timer.add(2, function()
      level:removeNode(fire)
      tile.state = 'burned'
    end)
  end
end

function Building:draw()
  if self.state == 'burning' or self.state == 'burned' then
    love.graphics.draw(self.burnt_image, self.x, self.y)
  end

  if self.state ~= 'burned' then
    for k,tile in pairs(self.tiles) do
      if tile.state ~= 'burned' then
        love.graphics.draw(self.image, tile.quad, tile.x, tile.y)
      end
    end
  end
end

return Building
