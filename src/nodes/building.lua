local app = require 'app'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local Fire = require 'nodes/fire'
local collision  = require 'hawk/collision'

local gamesave = app.gamesaves:active()

local Building = {}
Building.__index = Building
Building.isBuilding = true

function Building.new(node, collider, level)
  local building = {}
  setmetatable(building, Building)

  building.image = love.graphics.newImage('images/buildings/' .. level.name .. '/' .. node.name .. '.png')
  building.burnt_image = love.graphics.newImage('images/buildings/' .. level.name .. '/' .. node.name .. '_burned.png')
  building.image:setFilter('nearest', 'nearest')
  building.burnt_image:setFilter('nearest', 'nearest')

  building.trigger = node.properties.trigger or ''

  building.name = node.name
  building.x = node.x
  building.y = node.y
  building.width = node.width
  building.height = node.height

  building.state = 'default'

  building.tiles = {}
  building.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  building.node = node
  building.bb.node = building
  collider:setPassive(building.bb)

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
  local level = self.containerLevel

  -- Store all of the doors that are inside the building node
  self.doors = {}
  for k,door in pairs(level.nodes) do
    if door.isDoor and (door.node.x >= self.x and door.node.x <= self.x + self.width)
      and (door.node.y >= self.y and door.node.y <= self.y + self.height) then
      table.insert(self.doors, door)
    end
  end
  --Store all of the climbable nodes that are inside the building node
  self.climbables = {}
  for k,climbable in pairs(level.nodes) do
    if climbable.isClimbable and (climbable.position.x >= self.x and climbable.position.x <= self.x + self.width)
      and (climbable.position.y >= self.y and climbable.position.y <= self.y + self.height) then
      table.insert(self.climbables, climbable)
    end
  end

  -- If the building has already been burned, go into burned state
  if gamesave:get(self.name .. '_building_burned', false) then
    self.state = 'burned'
    self:burned()
    -- Remove collision tiles inside the building
    for k,tile in pairs(self.tiles) do
      collision.remove_tile(level.map, tile.x, tile.y, self.tilewidth, self.tileheight)
    end
  end

  -- If the npc trigger that shares the name of the
  -- building is dead and the building hasn't burned
  if gamesave:get(self.trigger, false) and not gamesave:get(self.name .. '_building_burned', false) then
    self:burn()
  end
end

---
-- Removes doors and makes the roof no longer solid
function Building:burned()
  gamesave:set(self.name .. '_building_burned', true)

  local level = self.containerLevel

  -- Remove all doors within the building node
  for k,door in pairs(self.doors) do
    level:removeNode(door)
  end
  -- Remove all climbable nodes within the building node
  for k,climbable in pairs(self.climbables) do
    level:removeNode(climbable)
  end
end

---
-- Start burning the building at the first row
function Building:burn()
  if self.state == 'burning' or self.state == 'burned' then return end
  self.state = 'burning'
  self:burned()
  Timer.add(3, function()
    if self.containerLevel:hasNode(self) then
      self:burn_row(1)
    end
  end)
end

---
-- Shuffles the row of tiles so they each start burning in a random order
-- @param row the table of tiles in the row that will be burned
function Building:burn_row(row)
  local column = {}
  for i=0, self.tileColumns do
    column[i] = i
  end
  column = utils.shuffle(column)

  for i=1, #column do
    local tile = self.tiles[(row * self.tileColumns - self.tileColumns) + (column[i] - 1)]
    if tile.state ~= 'burned' and tile.state ~= 'burning' then
      Timer.add(math.random(0.5,1), function()
        if self.containerLevel:hasNode(self) then
          self:burn_tile(row, tile)
        end
      end)
    end
  end

  if row < self.tileRows then
    Timer.add(math.random(1,1.5), function()
      self:burn_row(row + 1)
    end)
  end
end

---
-- Burns a tile of the building
-- @param tile the tile of the building that fire is added to
function Building:burn_tile(row, tile)
  tile.state = 'burning'

  local level = self.containerLevel

  -- Remove collision tile
  collision.remove_tile(level.map, tile.x, tile.y, self.tilewidth, self.tileheight)

  -- 1 or 2 fire nodes attached to this tile
  for i=1,math.random(1,2) do
    -- generate a slightly random offset for the fire node to be drawn at
    local position = {
      x = tile.x + math.random(-10, 10),
      y = tile.y + math.random(-10, 0)
    }

    -- Fire spreads from middle of buliding, outwards as it goes down rows
    -- This is just a hack so we don't get floating fire on the top row of a sloped roof
    if row == 1 and (tile.x + self.tilewidth ~= (self.x + (self.width / 2)))
                and (tile.x ~= (self.x + (self.width / 2))) then return end
    tile.width = self.tilewidth
    tile.height = self.tileheight
    local fire = Fire.new(tile)
    level:addNode(fire)

    -- Fire burns for 2 seconds and then sets removes itself and sets the tile to a burned state
    Timer.add(2, function()
      if fire then
        level:removeNode(fire)
      end
      tile.state = 'burned'
    end)
  end
end
---
-- Called when the building collides with a burning enemy
function Building:collide(node)
  if (node.burn == true) and gamesave:get(self.name .. '_building_burned', false) == false and self.state ~= 'burned' then
    self:burn()
  end
end

function Building:draw()
  -- Draw the burned building sprite if we are currently burning or have burned the building
  if self.state == 'burning' or self.state == 'burned' then
    love.graphics.draw(self.burnt_image, self.x, self.y)
  end

  -- If the building hasn't been totally burned yet, we still need to draw the tiles that haven't been burned
  if self.state ~= 'burned' then
    for k,tile in pairs(self.tiles) do
      if tile.state ~= 'burned' then
        love.graphics.draw(self.image, tile.quad, tile.x, tile.y)
      end
    end
  end
end

return Building
