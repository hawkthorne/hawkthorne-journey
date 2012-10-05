local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()

local map = {}
map.tileWidth = 12
map.tileHeight = 12
map.width = 193
map.height = 111

local scale = 2

local overworld = {
    love.graphics.newImage('images/world_01.png'),
    love.graphics.newImage('images/world_02.png'),
    love.graphics.newImage('images/world_03.png'),
    love.graphics.newImage('images/world_04.png'),
    love.graphics.newImage('images/world_05.png'),
    love.graphics.newImage('images/world_06.png'),
    love.graphics.newImage('images/world_07.png'),
    love.graphics.newImage('images/world_08.png'),
}

local overlay = {
    love.graphics.newImage('images/world_overlay_01.png'),
    love.graphics.newImage('images/world_overlay_02.png'),
    false,
    false,
    love.graphics.newImage('images/world_overlay_05.png'),
    love.graphics.newImage('images/world_overlay_06.png'),
    false,
    false,
}

local board = love.graphics.newImage('images/titleboard.png')

local worldsprite = love.graphics.newImage('images/overworld.png')

-- free_ride_ferry
local wheelchair = love.graphics.newImage('images/free_ride_ferry.png')
local wc_x1, wc_x2, wc_y1, wc_y2 = 1685, 1956, 816, 680
local offset_x, offset_y = math.floor( wheelchair:getHeight() / 2 ) - 10, math.floor( wheelchair:getWidth() / 2 )

local g = anim8.newGrid(25, 31, worldsprite:getWidth(), 
    worldsprite:getHeight())

-- animated water
local watersprite = love.graphics.newImage('images/world_water.png')
local h2o = anim8.newGrid(36, 36, watersprite:getWidth(), watersprite:getHeight())
local water = anim8.newAnimation('loop', h2o('1-2,1'), 1)

-- cloud puffs
local cloudpuffsprite = love.graphics.newImage('images/cloud_puff.png')
local spunk = anim8.newGrid(100,67, cloudpuffsprite:getWidth(), cloudpuffsprite:getHeight())
-- ( cloud animations will be generated on the fly )

-- gay sparkles
local sparklesprite = love.graphics.newImage('images/gay_sparkle.png')
local bling = anim8.newGrid(24, 24, sparklesprite:getWidth(), sparklesprite:getHeight())
local sparkles = {{1028,456},{1089,442},{1403,440},{1348,591},{1390,633},{1273,698},{1160,657},{1088,702},{1048,665},{1072,604},{1060,552},{1104,548},{1172,555},{1199,727},{1263,735},{1313,505},{1337,459},{1358,429},{1270,617},{1289,571},{1123,505},{1124,472},{1359,709},{1389,555},{1376,677},{1057,624},{1169,710},{1149,592},{1297,639}}
for _,_sp in pairs(sparkles) do
    _sp[3] = anim8.newAnimation('loop', bling('1-4,1','1-4,2'), ( math.random(15) / 100 ) + 0.15)
    _sp[3]:gotoFrame( math.random( 8 ) )
end

-- overworld clouds
local cloudquads = {
    love.graphics.newQuad(   0, 0, 100, 67, cloudpuffsprite:getWidth(), cloudpuffsprite:getHeight() ), --small
    love.graphics.newQuad( 100, 0, 100, 67, cloudpuffsprite:getWidth(), cloudpuffsprite:getHeight() ), --medium
    love.graphics.newQuad( 200, 0, 100, 67, cloudpuffsprite:getWidth(), cloudpuffsprite:getHeight() ), --large
    love.graphics.newQuad( 300, 0, 200, 67, cloudpuffsprite:getWidth(), cloudpuffsprite:getHeight() )  --x-large
}
local clouds = {}
function insertrandomcloud(nofade)
    table.insert( clouds, {
        x = math.random( map.width * map.tileWidth ), -- x position
        y = math.random( map.height * map.tileHeight ), -- y position
        q = math.random( #cloudquads ), -- quad ( cloud size )
        s = ( math.random( 15 ) + 5 ) * ( math.random(2) == 1 and 1 or -1 ), -- speed / direction
        o = nofade and 0.8 or 0 -- opacity
    } )
end
for i=0,15 do insertrandomcloud(true) end

-- overworld state machine
state.zones = {
    forest_1 = { x=66,  y=100, up=nil,        down=nil,        right='forest_2', left=nil,        name='Greendale',          level='studyroom'                                          },
    forest_2 = { x=91,  y=100, up='forest_3', down=nil,        right=nil,        left='forest_1', name='Forest',             level='forest'                                             },
    forest_3 = { x=91,  y=89,  up='town_1',   down='forest_2', right=nil,        left=nil,        name='Forest 2',           level='forest-2'                                           },
    forest_4 = { x=122, y=36,  up='forest_5', down=nil,        right=nil,        left='island_4', name=nil,                  level=nil                                                  },
    forest_5 = { x=122, y=22,  up=nil,        down='forest_4', right=nil,        left=nil,        name=nil,                  level=nil                                                  },
    town_1   = { x=91,  y=76,  up=nil,        down='forest_3', right=nil,        left='town_2',   name='Town',               level='town'                                               },
    town_2   = { x=71,  y=76,  up=nil,        down=nil,        right='town_1',   left='town_3',   name=nil,                  level=nil                                                  },
    town_3   = { x=51,  y=76,  up=nil,        down=nil,        right='town_2',   left='town_4',   name='New Abedtown',       level='new-abedtown'                                       },
    town_4   = { x=37,  y=76,  up='valley_1', down=nil,        right='town_3',   left=nil,        name='Village Forest',     level='village-forest'                                     },
    valley_1 = { x=37,  y=45,  up=nil,        down='town_4',   right='valley_2', left=nil,        name='Valley of Laziness', level='valley'                                             },
    valley_2 = { x=66,  y=45,  up='valley_3', down=nil,        right=nil,        left='valley_1', name='Valley of Laziness', level=nil,                bypass={right='up', down='left'} },
    valley_3 = { x=66,  y=36,  up=nil,        down='valley_2', right='island_1', left=nil,        name='Valley of Laziness', level=nil,                bypass={up='right', left='down'} },
    island_1 = { x=93,  y=36,  up=nil,        down='island_2', right=nil,        left='valley_3', name='Gay Island',         level=nil,                bypass={right='down', up='left'} },
    island_2 = { x=93,  y=56,  up='island_1', down=nil,        right='island_3', left=nil,        name='Gay Island',         level='gay-island'                                         },
    island_3 = { x=109, y=56,  up='island_4', down='island_5', right=nil,        left='island_2', name='Gay Island 2',       level='gay-island-2'                                       },
    island_4 = { x=109, y=36,  up=nil,        down='island_3', right='forest_4', left=nil,        name=nil,                  level=nil,                bypass={up='right', left='down'} },
    island_5 = { x=109, y=68,  up='island_3', down=nil,        right='ferry',    left=nil,        name=nil,                  level=nil                                                  },
    ferry    = { x=163, y=68,  up='caverns',  down=nil,        right=nil,        left='island_5', name='Free Ride Ferry',    level=nil,                bypass={down='left', right='up'} },
    caverns  = { x=163, y=44,  up=nil,        down='ferry',    right=nil,        left=nil,        name='Black Caverns',      level='black-caverns'                                      },
}


function state:init()
    self:reset()
end

function state:enter(previous, character)
    camera:scale(scale, scale)
    camera.max.x = map.width * map.tileWidth - (window.width * 2)

    fonts.set( 'big' )

    sound.playMusic( "overworld" )

    if character then
        self.character = character
        self.stand = anim8.newAnimation('once', g(character.ow, 1), 1)
        self.walk = anim8.newAnimation('loop', g(character.ow,2,character.ow,3), 0.2)
        self.facing = 1
        self:reset()
    end

end

function state:leave()
    camera:scale(window.scale)
    fonts.reset()
end

function state:reset()
    self.zone = self.zones['forest_1']
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
    water:update(dt)
    
    for _,_sp in pairs(sparkles) do
        _sp[3]:update(dt)
    end
    
    for i,cloud in pairs( clouds ) do
        if cloud then
            cloud.x = cloud.x + ( cloud.s * dt ) / ( cloud.q / 2 )
            if cloud.o <= 0.8 then cloud.o = cloud.o + dt end -- fade in
            --check for out of bounds
            if cloud.x + 200 < 0 or cloud.x > map.width * map.tileWidth then
                clouds[i] = false
                insertrandomcloud()
            end
        end
    end

    self.walk:update(dt)
    local dx = self.vx * dt * 300
    local dy = self.vy * dt * 300
    self.tx = self.tx + dx
    self.ty = self.ty + dy

    if self.pzone and self.moving then
        if ( self.tx / map.tileHeight ) * self.vx <= lerp(self.pzone.x, self.zone.x, 0.5) * self.vx and
           ( self.ty / map.tileWidth ) * self.vy  <= lerp(self.pzone.y, self.zone.y, 0.5) * self.vy then
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
            _spunk = anim8.newAnimation('once', spunk('1-3,1'), 0.2),
            x = self.spunk_x,
            y = self.spunk_y,
            dx = ( rand == 3 and self.spunk_dx or ( rand == 2 and 0 or -self.spunk_dx ) ),
            dy = self.spunk_dy
        })
    end
    for i,_spunk in pairs(self.spunks) do
        if _spunk then
            _spunk.x = _spunk.x + _spunk.dx * dt
            _spunk.y = _spunk.y + _spunk.dy * dt
            _spunk._spunk:update(dt)
            if _spunk.y + ( cloudpuffsprite:getHeight() * 2 ) < 0 then
                self.spunks[i] = nil
            end
        end
    end

    camera:setPosition(self.tx - window.width * scale / 2, self.ty - window.height * scale / 2)
end

local mapping = {
    w='up',
    s='down',
    a='left',
    d='right',
}

function state:move(key)
    if key == 'up' and self.zone.up then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.up]
        self.moving = 'up'
        self.vx = 0
        self.vy = -1
        self.entered = key
    elseif key == 'down' and self.zone.down then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.down]
        self.moving = 'down'
        self.vx = 0
        self.vy = 1
        self.entered = key
    elseif key == 'left' and self.zone.left then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.left]
        self.moving = 'left'
        self.facing = -1
        self.vx = -1
        self.vy = 0
        self.entered = key
    elseif key == 'right' and self.zone.right then
        self.pzone = self.zone
        self.zone = self.zones[self.zone.right]
        self.moving = 'right'
        self.facing = 1
        self.vx = 1
        self.vy = 0
        self.entered = key
    end
end
 
function state:keypressed(key)
    if key == 'escape' then
        Gamestate.switch('pause')
        return
    end

    if self.moving then
        return
    end

    if key == 'return' or key == 'kpenter' then
        if not self.zone.level then
            return
        end

        local level = Gamestate.get(self.zone.level)
        Gamestate.load(self.zone.level, level.new(level.name))
        Gamestate.switch(self.zone.level, self.character)
    end

    if mapping[key] then
        key = mapping[key]
    end

    self:move(key)
end

function state:title()
    local zone = self.zone
    if self.pzone and self.show_prev_zone_name then
        zone = self.pzone
    end
    if not zone.name and not zone.level then
        return 'UNCHARTED'
    else
        return zone.name
    end
end

function state:draw()
    love.graphics.setBackgroundColor(133, 185, 250)

    for x=math.floor( camera.x / 36 ), math.floor( ( camera.x + camera:getWidth() ) / 36 ) do
        for y=math.floor( camera.y / 36 ), math.floor( ( camera.y + camera:getHeight() ) / 36 ) do
            water:draw(watersprite, x * 36, y * 36 )
        end
    end

    for i, image in ipairs(overworld) do
        local x = (i - 1) % 4
        local y = i > 4 and 1 or 0
        love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
    end

    for _,_spunk in pairs(self.spunks) do
        if _spunk then
            _spunk._spunk:draw( cloudpuffsprite, _spunk.x, _spunk.y )
        end
    end
    
    for _,_sp in pairs(sparkles) do
        _sp[3]:draw( sparklesprite, _sp[1] - 12, _sp[2] - 12 )
    end

    local face_offset = self.facing == -1 and 25 or 0
    if self.moving then
        self.walk:draw(worldsprite, math.floor(self.tx) + face_offset, math.floor(self.ty) - 15,0,self.facing,1)
    else
        self.stand:draw(worldsprite, math.floor(self.tx) + face_offset, math.floor(self.ty) - 15,0,self.facing,1)
    end

    if  ( self.ty == wc_y1 and self.tx > wc_x1 and self.tx <= wc_x2 ) or
        ( self.tx == wc_x2 and self.ty > wc_y2 and self.ty <= wc_y1 ) then
        -- follow the player
        love.graphics.draw( wheelchair, self.tx - offset_x, self.ty - offset_y )
    elseif self.zone == self.zones['caverns'] or
        ( self.tx == wc_x2 and self.ty <= wc_y2 ) then
        -- cavern dock
        love.graphics.draw( wheelchair, wc_x2 - offset_x, wc_y2 - offset_y )
    else
        -- island dock
        love.graphics.draw( wheelchair, wc_x1 - offset_x, wc_y1 - offset_y )
    end

    for i, image in ipairs(overlay) do
        if image then
            local x = (i - 1) % 4
            local y = i > 4 and 1 or 0
            love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
        end
    end
    
    for _,cloud in pairs( clouds ) do
        if cloud then
            love.graphics.setColor( 255, 255, 255, cloud.o * 255 )
            love.graphics.drawq( cloudpuffsprite, cloudquads[cloud.q], cloud.x, cloud.y )
            love.graphics.setColor( 255, 255, 255, 255 )
        end
    end

    love.graphics.draw(board, camera.x + window.width - board:getWidth() / 2,
                              camera.y + window.height + board:getHeight() * 2)

    love.graphics.printf(self:title(),
                         camera.x + window.width - board:getWidth() / 2,
                         camera.y + window.height + board:getHeight() * 2.5 - 10,
                         board:getWidth(), 'center')
end

function lerp(a,b,t) return a+(b-a)*t end

return state
