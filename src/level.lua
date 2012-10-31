local Gamestate = require 'vendor/gamestate'
local Queue = require 'queue'
local anim8 = require 'vendor/anim8'
local tmx = require 'vendor/tmx'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local window = require 'window'
local sound = require 'vendor/TEsound'
local controls = require 'controls'
local HUD = require 'hud'
local music = {}

local node_cache = {}
local tile_cache = {}

local Player = require 'player'
local Floor = require 'nodes/floor'
local Platform = require 'nodes/platform'
local Wall = require 'nodes/wall'

local function limit( x, min, max )
    return math.min(math.max(x,min),max)
end

local function load_tileset(name)
    if tile_cache[name] then
        return tile_cache[name]
    end
    
    local tileset = tmx.load(require("maps/" .. name))
    tile_cache[name] = tileset
    return tileset
end

local function load_node(name)
    if node_cache[name] then
        return node_cache[name]
    end
    local node = require('nodes/' .. name)
    node_cache[name] = node
    return node
end


function math.sign(x)
    if x == math.abs(x) then
        return 1
    else
        return -1
    end
end

-- Return the default Abed character
local function defaultCharacter()
    local abed = require 'characters/abed'
    return abed.new(love.graphics.newImage('images/characters/abed/base.png'))
end


local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    local player, node, node_a, node_b

    if shape_a.player then
        player = shape_a.player
        node = shape_b.node
    elseif shape_b.player then
        player = shape_b.player
        node = shape_a.node
    else
        node_a = shape_a.node
        node_b = shape_b.node
    end

    if node then
        node.player_touched = true

        if node.collide then
            node:collide(player, dt, mtv_x, mtv_y)
        end
    elseif node_a then
        if node_a.collide then
            node_a:collide(node_b, dt, mtv_x, mtv_y)
        end
        if node_b.collide then
            node_b:collide(node_a, dt, mtv_x, mtv_y)
        end
    end

end

-- this is called when two shapes stop colliding
local function collision_stop(dt, shape_a, shape_b)
    local player, node

    if shape_a.player then
        player = shape_a.player
        node = shape_b.node
    else
        player = shape_b.player
        node = shape_a.node
    end

    if not node then
        return
    end

    node.player_touched = false

    if node.collide_end then
        node:collide_end(player, dt)
    end
end

local function setBackgroundColor(map)
    local prop = map.properties
    if not prop.red then
        love.graphics.setBackgroundColor(0, 0, 0)
        return
    end
    love.graphics.setBackgroundColor(tonumber(prop.red),
                                     tonumber(prop.green),
                                     tonumber(prop.blue))
end

local function getCameraOffset(map)
    local prop = map.properties
    if not prop.offset then
        return 0
    end
    return tonumber(prop.offset) * map.tilewidth
end

local function getWarpIn(map)
    local prop = map.properties
    return prop.warpin and true or false 
end

local function getTitle(map)
    local prop = map.properties
    return prop.title or "UNKNOWN"
end

local function getSoundtrack(map)
    local prop = map.properties
    return prop.soundtrack or "level"
end

local function jumpingAllowed(map)
    local prop = map.properties
    return prop.jumping ~= 'false'
end


local Level = {}
Level.__index = Level
Level.level = true

function Level.new(name)
    local level = {}
    setmetatable(level, Level)

    level.character = character
    level.over = false
    level.name = name

    assert( love.filesystem.exists( "maps/" .. name .. ".lua" ),
            "maps/" .. name .. ".lua not found.\n\n" ..
            "Have you generated your maps lately?\n\n" ..
            "LINUX / OSX: run 'make maps'\n" ..
            "WINDOWS: use tmx2lua to generate\n\n" ..
            "Check the documentation for more info."
    )

    level.map = require("maps/" .. name)
    level.background = load_tileset(name)
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)
    level.music = getSoundtrack(level.map)
    level.jumping = jumpingAllowed(level.map)
    level.spawn = 'studyroom'
    level.title = getTitle(level.map)
    level.character = defaultCharacter()

    level.pan = 0
    level.pan_delay = 1
    level.pan_distance = 80
    level.pan_speed = 140
    level.pan_hold_up = 0
    level.pan_hold_down = 0

    level.player = Player.factory(level.collider)
    level.player:loadCharacter(level.character)
    level.player.boundary = {width=level.map.width * level.map.tilewidth}

    level.nodes = {}
    level.entrances = {}

    level.default_position = {x=0, y=0}
    level.player.isFloorspace = false;
    for k,v in pairs(level.map.objectgroups.nodes.objects) do
        if v.type == 'floorspace' then --special cases are bad
            level.player.crouch_state = 'crouchwalk'
            level.player.gaze_state = 'gazewalk'
            level.player.isFloorspace = true;
        end

        if v.type == 'entrance' then
            if v.properties.name then
                level.entrances[v.properties.name] = {x=v.x, y=v.y}
            else
                level.default_position = {x=v.x, y=v.y}
            end
            level.player.position = level.default_position
        else
            node = load_node(v.type)
            if node then
                table.insert(level.nodes, node.new(v, level.collider, level.map))
            end
        end
    end

    if level.map.objectgroups.floor then
        for k,v in pairs(level.map.objectgroups.floor.objects) do
            local floor = Floor.new(v, level.collider)
        end
    end

    if level.map.objectgroups.platform then
        for k,v in pairs(level.map.objectgroups.platform.objects) do
            table.insert(level.nodes, Platform.new(v, level.collider))
        end
    end

    if level.map.objectgroups.wall then
        for k,v in pairs(level.map.objectgroups.wall.objects) do
            local floor = Wall.new(v, level.collider)
        end
    end

    level.player = player
    
    return level
end

function Level:restartLevel()
    --Player in level: "..self.name)

    self.player = Player.factory(self.collider)
    self.player:refreshPlayer(self.collider)
    self.player:loadCharacter(self.character)
    self.player.boundary = {width=self.map.width * self.map.tilewidth}
    
    self.player.position = self.default_position

    for k,v in pairs(self.map.objectgroups.nodes.objects) do
        if v.type == 'floorspace' then --special cases are bad
            self.player.crouch_state = 'crouchwalk'
            self.player.gaze_state = 'gazewalk'
        end
   end
    
end

function Level:enter(previous, character)

    --only restart if it's an ordinary level
    if previous.level or previous==Gamestate.get('overworld') then
        self.previous = previous
        self:restartLevel()
    end

    camera.max.x = self.map.width * self.map.tilewidth - window.width

    setBackgroundColor(self.map)

    sound.playMusic( self.music )

    if character then
        self.character = character
        self.player:loadCharacter(self.character)
        if getWarpIn(self.map) then
            self.player:respawn()
        end
    end
    
    self.hud = HUD.new(self)

    for i,node in ipairs(self.nodes) do
        if node.enter then node:enter(previous, character) end
    end
end



function Level:init()
end

function Level:update(dt)
    self.player:update(dt)

    -- falling off the bottom of the map
    if self.player.position.y - self.player.height > self.map.height * self.map.tileheight then
        self.player.health = 0
        self.player.state = 'dead'
    end

    -- start death sequence
    if self.player.state == 'dead' and not self.over then
        sound.stopMusic()
        sound.playSfx( 'death' )
        self.over = true
        self.respawn = Timer.add(3, function() 
            Gamestate.get('overworld'):reset()
            Gamestate.switch(Level.new(self.spawn), self.character)
        end)
    end

    self.collider:update(dt)

    for i,node in ipairs(self.nodes) do
        if node.update then node:update(dt, self.player) end
    end

    local up = controls.isDown( 'UP' )
    local down = controls.isDown( 'DOWN' )

    if up then
        self.pan_hold_up = self.pan_hold_up + dt
    else
        self.pan_hold_up = 0
    end
    
    if down then
        self.pan_hold_down = self.pan_hold_down + dt
    else
        self.pan_hold_down = 0
    end

    if up and self.pan_hold_up >= self.pan_delay then
        self.pan = math.max( self.pan - dt * self.pan_speed, -self.pan_distance )
    elseif down and self.pan_hold_down >= self.pan_delay then
        self.pan = math.min( self.pan + dt * self.pan_speed, self.pan_distance )
    else
        if self.pan > 0 then
            self.pan = math.max( self.pan - dt * self.pan_speed, 0 )
        elseif self.pan < 0 then
            self.pan = math.min( self.pan + dt * self.pan_speed, 0 )
        end
    end

    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tilewidth * 4.5
    camera:setPosition( math.max(x - window.width / 2, 0),
                        limit( limit(y, 0, self.offset) + self.pan, 0, self.offset ) )

    Timer.update(dt)
end

function Level:quit()
    if self.respawn ~= nil then
        Timer.cancel(self.respawn)
    end
end

function Level:draw()
    self.background:draw(0, 0)

    for i,node in ipairs(self.nodes) do
        if node.draw and not node.foreground then node:draw() end
    end

    self.player:draw()

    for i,node in ipairs(self.nodes) do
        if node.draw and node.foreground then node:draw() end
    end
    
    self.hud:draw( self.player )
end

function Level:leave()
    for i,node in ipairs(self.nodes) do
        if node.leave then node:leave() end
    end
end

function Level:keyreleased( button )
    self.player:keyreleased( button, self )
end

function Level:keypressed( button )
    if button == 'START' and self.player.state ~= 'dead' then
        Gamestate.switch('pause')
        return
    end
    
    self.player:keypressed( button, self )
    self.player.inventory:keypressed( button, self.player)

    for i,node in ipairs(self.nodes) do
        if node.player_touched and node.keypressed then
            node:keypressed( button, self.player)
        end
    end
end

return Level
