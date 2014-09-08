local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local utils = require 'utils'
local Player = require 'player'
local character = require 'character'

local state = Gamestate.new()

local map = {}
map.tileWidth = 12
map.tileHeight = 12
map.width = 193
map.height = 111

local scale = 2

-- FIXME: Put in a JSON file
-- overworld state machine
state.zones = {
    greendale= { x=66,  y=100, UP=nil,        DOWN=nil,        RIGHT='forest_2', LEFT=nil,        visited = true,  name='Greendale',           level='studyroom'                                          },
    forest_2 = { x=91,  y=100, UP='forest_3', DOWN=nil,        RIGHT=nil,        LEFT='greendale',visited = false,  name='Forest',             level='forest'                                             },
    forest_3 = { x=91,  y=89,  UP='town_1',   DOWN='forest_2', RIGHT=nil,        LEFT=nil,        visited = false,  name='Forest',             level='forest-2'                                           },
    town_1   = { x=91,  y=76,  UP=nil,        DOWN='forest_3', RIGHT=nil,        LEFT='town_2',   visited = false,  name='Town',               level='town'                                               },
    town_2   = { x=71,  y=76,  UP=nil,        DOWN=nil,        RIGHT='town_1',   LEFT='vforest_1',visited = true,  name='New Abedtown',        level='new-abedtown'                                       },
    vforest_1= { x=51,  y=76,  UP=nil,        DOWN=nil,        RIGHT='town_2',   LEFT='vforest_2',visited = false,  name='Village Forest',     level='treeline'                                           },
    vforest_2= { x=37,  y=76,  UP='valley_1', DOWN=nil,        RIGHT='vforest_1',LEFT=nil,        visited = false,  name='Village Forest',     level='village-forest'                                     },
    valley_1 = { x=37,  y=45,  UP=nil,        DOWN='vforest_2',RIGHT='valley_2', LEFT=nil,        visited = false,  name='Valley of Laziness', level='valley'                                             },
    valley_2 = { x=66,  y=45,  UP='valley_3', DOWN=nil,        RIGHT=nil,        LEFT='valley_1', visited = false,  name='Valley of Laziness', level=nil,                bypass={RIGHT='UP', DOWN='LEFT'} },
    valley_3 = { x=66,  y=36,  UP=nil,        DOWN='valley_2', RIGHT='island_1', LEFT=nil,        visited = false,  name='Valley of Laziness', level=nil,                bypass={UP='RIGHT', LEFT='DOWN'} },
    island_1 = { x=93,  y=36,  UP=nil,        DOWN='island_2', RIGHT=nil,        LEFT='valley_3', visited = false,  name='Gay Island',         level=nil,                bypass={RIGHT='DOWN', UP='LEFT'} },
    island_2 = { x=93,  y=56,  UP='island_1', DOWN=nil,        RIGHT='island_3', LEFT=nil,        visited = false,  name='Gay Island',         level='gay-island'                                         },
    island_3 = { x=109, y=56,  UP='island_4', DOWN='island_5', RIGHT=nil,        LEFT='island_2', visited = false,  name='Gay Island',         level='gay-island-2'                                       },
    island_4 = { x=109, y=36,  UP=nil,        DOWN='island_3', RIGHT='forest_4', LEFT=nil,        visited = false,  name=nil,                  level=nil,                bypass={UP='RIGHT', LEFT='DOWN'} },
    forest_4 = { x=122, y=36,  UP='forest_5', DOWN=nil,        RIGHT=nil,        LEFT='island_4', visited = false,  name=nil,                  level=nil                                                  },
    forest_5 = { x=122, y=22,  UP=nil,        DOWN='forest_4', RIGHT=nil,        LEFT=nil,        visited = false,  name=nil,                  level=nil                                                  },
    island_5 = { x=109, y=68,  UP='island_3', DOWN=nil,        RIGHT='ferry',    LEFT=nil,        visited = false,  name='Gay Island',         level='gay-island-4'                                       },
    ferry    = { x=163, y=68,  UP='caverns',  DOWN=nil,        RIGHT=nil,        LEFT='island_5', visited = false,  name='Free Ride Ferry',    level=nil,                bypass={DOWN='LEFT', RIGHT='UP'} },
    caverns  = { x=163, y=44,  UP=nil,        DOWN='ferry',    RIGHT=nil,        LEFT=nil,        visited = false,  name='Black Caverns',      level='black-caverns'                                      },
}


function state:init()
  self.name = 'overworld'
  self:reset()
end

function state:insertrandomcloud(map, nofade)
  table.insert(self.clouds, {
      x = math.random(map.width * map.tileWidth), -- x position
      y = math.random(map.height * map.tileHeight), -- y position
      q = math.random(#self.cloudquads), -- quad ( cloud size )
      s = (math.random(15) + 5) * (math.random(2) == 1 and 1 or -1), -- speed / direction
      o = nofade and 0.8 or 0 -- opacity
  })
end

function state:enter(previous)
  self.overworld = {
    love.graphics.newImage('images/overworld/world_01.png'),
    love.graphics.newImage('images/overworld/world_02.png'),
    love.graphics.newImage('images/overworld/world_03.png'),
    love.graphics.newImage('images/overworld/world_04.png'),
    love.graphics.newImage('images/overworld/world_05.png'),
    love.graphics.newImage('images/overworld/world_06.png'),
    love.graphics.newImage('images/overworld/world_07.png'),
    love.graphics.newImage('images/overworld/world_08.png'),
  }
  
  self.overlay = {
    love.graphics.newImage('images/overworld/world_overlay_01.png'),
    love.graphics.newImage('images/overworld/world_overlay_02.png'),
    false,
    false,
    love.graphics.newImage('images/overworld/world_overlay_05.png'),
    love.graphics.newImage('images/overworld/world_overlay_06.png'),
    false,
    false,
  }

  self.board = love.graphics.newImage('images/overworld/titleboard.png')

  local current = character.current()

  self.charactersprites = love.graphics.newImage('images/characters/' .. current.name .. '/overworld.png')

  local g = anim8.newGrid(36, 36, self.charactersprites:getWidth(), self.charactersprites:getHeight())

  --flags
  self.flag_image = love.graphics.newImage('images/overworld/flag.png')
  self.flags = {}

  -- free_ride_ferry
  self.wheelchair = love.graphics.newImage('images/overworld/free_ride_ferry.png')
  self.wc_x1, self.wc_x2, self.wc_y1, self.wc_y2 = 1685, 1956, 816, 680
  self.offset_x, self.offset_y = math.floor(self.wheelchair:getHeight() / 2 ) - 10, math.floor(self.wheelchair:getWidth() / 2 )
  
  -- animated water
  self.watersprite = love.graphics.newImage('images/overworld/world_water.png')
  self.h2o = anim8.newGrid(36, 36, self.watersprite:getWidth(), self.watersprite:getHeight())
  self.water = anim8.newAnimation('loop', self.h2o('1-2,1'), 1)
  
  -- cloud puffs
  self.cloudpuffsprite = love.graphics.newImage('images/overworld/cloud_puff.png')
  self.spunk_image = anim8.newGrid(100,67, self.cloudpuffsprite:getWidth(), self.cloudpuffsprite:getHeight())
  -- ( cloud animations will be generated on the fly )
  
  -- gay sparkles
  self.sparklesprite = love.graphics.newImage('images/overworld/gay_sparkle.png')
  self.bling = anim8.newGrid(24, 24, self.sparklesprite:getWidth(), self.sparklesprite:getHeight())
  self.sparkles = {
    {1028,456},{1089,442},{1403,440},{1348,591},{1390,633},{1273,698},{1160,657},{1088,702},{1048,665},{1072,604},
    {1060,552},{1104,548},{1172,555},{1199,727},{1263,735},{1313,505},{1337,459},{1358,429},{1270,617},{1289,571},
    {1123,505},{1124,472},{1359,709},{1389,555},{1376,677},{1057,624},{1169,710},{1149,592},{1297,639}
  }

  for _,_sp in pairs(self.sparkles) do
    _sp[3] = anim8.newAnimation('loop', self.bling('1-4,1','1-4,2'), (math.random(15) / 100) + 0.15)
    _sp[3]:gotoFrame(math.random( 8 ))
  end

  -- overworld clouds
  self.cloudquads = {
    love.graphics.newQuad(   0, 0, 100, 67, self.cloudpuffsprite:getWidth(), self.cloudpuffsprite:getHeight() ), --small
    love.graphics.newQuad( 100, 0, 100, 67, self.cloudpuffsprite:getWidth(), self.cloudpuffsprite:getHeight() ), --medium
    love.graphics.newQuad( 200, 0, 100, 67, self.cloudpuffsprite:getWidth(), self.cloudpuffsprite:getHeight() ), --large
    love.graphics.newQuad( 300, 0, 200, 67, self.cloudpuffsprite:getWidth(), self.cloudpuffsprite:getHeight() )  --x-large
  }

  self.clouds = {}

  for i=0,15 do 
    self:insertrandomcloud(map, true)
  end

  self.previous = previous

  local owd = current:getOverworld()
  local charactersprites = love.graphics.newImage('images/characters/' .. current.name .. '/overworld.png')

  g = anim8.newGrid(36, 36, self.charactersprites:getWidth(), self.charactersprites:getHeight())

  camera:scale(scale, scale)
  camera.max.x = map.width * map.tileWidth - (window.width * 2)

  fonts.set('big')

  sound.playMusic("overworld")

  self.stand = anim8.newAnimation('once', g(owd, 1), 1)
  self.walk = anim8.newAnimation('loop', g(owd, 2, owd, 3), 0.2)
  self.facing = 1

  local player = Player.factory()

  for _,level in ipairs(player.visitedLevels) do
      for _,mapInfo in pairs(self.zones) do
          if mapInfo.level == level then
              mapInfo.visited = true
              table.insert(self.flags, {
                  x = mapInfo.x,
                  y = mapInfo.y
              })
              break
          end
      end
  end
  
  self:reset(player.currentLevel.overworldName)
end


function state:leave()
  camera:scale(window.scale)
  fonts.reset()

  self.cloudquads = nil
  self.clouds = nil
  self.watersprite = nil
  self.h2o = nil
  self.water = nil

  -- cloud puffs
  self.cloudpuffsprite = nil
  self.spunk_image = nil

  self.sparklesprite = nil
  self.bling = nil
  self.sparkles = nil
  self.overworld = nil
  self.overlay = nil
  self.board = nil
  self.charactersprites = nil
  self.flag_image = nil
  self.flags = nil
  self.spunks = nil
end

function state:reset(level)
    if not self.zones[level] then level = 'greendale' end
    self.zone = self.zones[level]
    self.tx = self.zone.x * map.tileWidth --self.zone.x * map.tileWidth
    self.ty = self.zone.y * map.tileHeight --self.zone.y * map.tileWidth
    self.vx = 0
    self.vy = 0
    self.moving = false
    self.entered = false
    self.spunk_counter = 0
    self.spunk_rate = 1.5
    self.spunk_x = 1170
    self.spunk_y = 460
    self.spunk_dx = 20
    self.spunk_dy = -100
    self.spunks = {}
end

function state:update(dt)
    self.water:update(dt)
    
    for _,_sp in pairs(self.sparkles) do
        _sp[3]:update(dt)
    end
    
    for i,cloud in pairs(self.clouds) do
        if cloud then
            cloud.x = cloud.x + ( cloud.s * dt ) / ( cloud.q / 2 )
            if cloud.o <= 0.8 then cloud.o = cloud.o + dt end -- fade in
            --check for out of bounds
            if cloud.x + 200 < 0 or cloud.x > map.width * map.tileWidth then
                self.clouds[i] = false
                self:insertrandomcloud(map)
            end
        end
    end

    self.walk:update(dt)
    local dx = self.vx * dt * 300
    local dy = self.vy * dt * 300
    self.tx = self.tx + dx
    self.ty = self.ty + dy

    if self.pzone and self.moving then
        if ( self.tx / map.tileHeight ) * self.vx <= utils.lerp(self.pzone.x, self.zone.x, 0.5) * self.vx and
           ( self.ty / map.tileWidth ) * self.vy  <= utils.lerp(self.pzone.y, self.zone.y, 0.5) * self.vy then
            self.show_prev_zone_name = true
        else
            self.show_prev_zone_name = false
        end
    end

    if math.abs(self.tx - self.zone.x * map.tileWidth) <= math.abs(dx) and 
        math.abs(self.ty - self.zone.y * map.tileHeight) <= math.abs(dy) then
        self.tx = self.zone.x * map.tileWidth
        self.ty = self.zone.y * map.tileHeight
        self.vx = 0
        self.vy = 0

        if self.entered and self.zone.bypass then
            self.show_prev_zone_name = true
            self:move(self.zone.bypass[self.entered])
        else
            self.moving = false
            self.entered = false
        end
    end
    
    self.spunk_counter = self.spunk_counter + dt
    if self.spunk_counter > self.spunk_rate then
        self.spunk_counter = 0
        -- release a new spunk
        local rand = math.random(3)
        table.insert(self.spunks, {
            spunk = anim8.newAnimation('once', self.spunk_image('1-3,1'), 0.2),
            x = self.spunk_x,
            y = self.spunk_y,
            dx = ( rand == 3 and self.spunk_dx or ( rand == 2 and 0 or -self.spunk_dx ) ),
            dy = self.spunk_dy
        })
    end
    for i,spunk in pairs(self.spunks) do
        if spunk then
            spunk.x = spunk.x + spunk.dx * dt
            spunk.y = spunk.y + spunk.dy * dt
            spunk.spunk:update(dt)
            if spunk.y + (self.cloudpuffsprite:getHeight() * 2 ) < 0 then
                self.spunks[i] = nil
            end
        end
    end

    camera:setPosition(self.tx - window.width * scale / 2, self.ty - window.height * scale / 2)
end

function state:move( button )
    if button == "UP" and self.zone.UP then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.UP]
        self.moving = 'up'
        self.vx = 0
        self.vy = -1
        self.entered = button
    elseif button == "DOWN" and self.zone.DOWN then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.DOWN]
        self.moving = 'down'
        self.vx = 0
        self.vy = 1
        self.entered = button
    elseif button == "LEFT" and self.zone.LEFT then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.LEFT]
        self.moving = 'LEFT'
        self.facing = -1
        self.vx = -1
        self.vy = 0
        self.entered = button
    elseif button == "RIGHT" and self.zone.RIGHT then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.RIGHT]
        self.moving = 'RIGHT'
        self.facing = 1
        self.vx = 1
        self.vy = 0
        self.entered = button
    end
end
 
function state:keypressed( button )
    if button == "START" then
        Gamestate.switch(self.previous)
        return
    end

    if self.moving then return end

    if button == "SELECT" or button == "JUMP" or button == "ATTACK" then
        if not self.zone.visited or not self.zone.level then
            sound.playSfx("cancel")
            return
        end

        local level = Gamestate.get(self.zone.level)

        local coordinates = level.default_position
        level.player = Player.factory() --no collider necessary yet
        --set the position before the switch to prevent automatic exiting from touching instant doors
        level.player.position = {x=coordinates.x, y=coordinates.y} -- Copy, or player position corrupts entrance data

        Gamestate.switch(self.zone.level)
    end

    self:move( button )
end

function state:title()
    local zone = self.zone
    if self.pzone and self.show_prev_zone_name then
        zone = self.pzone
    end
    if not zone.name and not zone.level or  not zone.visited then
        return 'UNCHARTED'
    else
        return zone.name
    end
end

function state:draw()

  love.graphics.setBackgroundColor(133, 185, 250)

    for x=math.floor(camera.x / 36), math.floor((camera.x + camera:getWidth()) / 36) do
        for y=math.floor(camera.y / 36), math.floor((camera.y + camera:getHeight()) / 36) do
            self.water:draw(self.watersprite, x * 36, y * 36 )
        end
    end

    for i, image in ipairs(self.overworld) do
        local x = (i - 1) % 4
        local y = i > 4 and 1 or 0
        love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
    end

    for _,spunk in pairs(self.spunks) do
        if spunk then
            spunk.spunk:draw(self.cloudpuffsprite, spunk.x, spunk.y )
        end
    end
    
    for _,_sp in pairs(self.sparkles) do
        _sp[3]:draw(self.sparklesprite, _sp[1] - 12, _sp[2] - 12 )
    end

    --flags
    for _,flag in pairs(self.flags) do
        if flag then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(self.flag_image, flag['x'] * map.tileWidth + 10, flag['y'] * map.tileHeight - 24)
        end
    end

    local face_offset = self.facing == -1 and 36 or 0

    if self.moving then
        self.walk:draw(self.charactersprites, math.floor(self.tx) + face_offset - 7, math.floor(self.ty) - 15,0,self.facing,1)
    else
        self.stand:draw(self.charactersprites, math.floor(self.tx) + face_offset - 7, math.floor(self.ty) - 15,0,self.facing,1)
    end

    if  (self.ty == self.wc_y1 and self.tx > self.wc_x1 and self.tx <= self.wc_x2) or
        (self.tx == self.wc_x2 and self.ty > self.wc_y2 and self.ty <= self.wc_y1) then
        -- follow the player
        love.graphics.draw(self.wheelchair, self.tx - self.offset_x, self.ty - self.offset_y)
    elseif self.zone == self.zones['caverns'] or
        ( self.tx == self.wc_x2 and self.ty <= self.wc_y2 ) then
        -- cavern dock
        love.graphics.draw(self.wheelchair, self.wc_x2 - self.offset_x, self.wc_y2 - self.offset_y)
    else
        -- island dock
        love.graphics.draw(self.wheelchair, self.wc_x1 - self.offset_x, self.wc_y1 - self.offset_y)
    end

    for i, image in ipairs(self.overlay) do
        if image then
            local x = (i - 1) % 4
            local y = i > 4 and 1 or 0
            love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
        end
    end

    love.graphics.setColor(255, 255, 255, 255)
    
    for _,cloud in pairs(self.clouds) do
        if cloud then
            love.graphics.setColor( 255, 255, 255, cloud.o * 255 )
            love.graphics.draw(self.cloudpuffsprite, self.cloudquads[cloud.q], cloud.x, cloud.y )
            love.graphics.setColor( 255, 255, 255, 255 )
        end
    end

    love.graphics.draw(self.board, camera.x + window.width - self.board:getWidth() / 2,
                              camera.y + window.height + self.board:getHeight() * 2)

    love.graphics.printf(self:title(),
                         camera.x + window.width - self.board:getWidth() / 2,
                         camera.y + window.height + self.board:getHeight() * 2.5 - 10,
                         self.board:getWidth(), 'center')
end

return state
