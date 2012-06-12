local Gamestate = require 'vendor/gamestate'
local Queue = require 'queue'
local anim8 = require 'vendor/anim8'
local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local window = require 'window'
local music = {}

local background = love.audio.newSource("audio/level.ogg")
background:setLooping(true)

-- assest cache
local node_cache = {}
local tile_cache = {}

local Player = require 'player'
local Floor = require 'nodes/floor'
local Wall = require 'nodes/wall'

function load_tileset(name)
    if tile_cache[name] then
        return tile_cache[name]
    end

    local tileset = atl.Loader.load(name)
    tile_cache[name] = tileset
    return tileset
end

function load_node(name)
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


local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
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

    node.player_touched = true

    if node.collide then
        node:collide(player, dt, mtv_x, mtv_y)
    end
end

-- this is called when two shapes stop colliding
local function collision_stop(dt, shape_a, shape_b)
    local node = shape_a.node or shape_b.node

    if node then
        node.player_touched = false
    end

    if node and node.collide_end then
        node:collide_end(nil, dt, mtv_x, mtv_y)
    end
end

local function setBackgroundColor(map)
    local prop = map.tileLayers.background.properties
    if not prop.red then
        love.graphics.setBackgroundColor(0, 0, 0)
        return
    end
    love.graphics.setBackgroundColor(tonumber(prop.red),
                                     tonumber(prop.green),
                                     tonumber(prop.blue))
end

local function getCameraOffset(map)
    local prop = map.tileLayers.background.properties
    if not prop.offset then
        return 0
    end
    return tonumber(prop.offset) * map.tileWidth
end

local function getSoundtrack(map)
    local prop = map.tileLayers.background.properties
    if not prop.soundtrack then
        return background
    end
    local audio = love.audio.newSource(prop.soundtrack)
    audio:setLooping(true)
    return audio
end


local Level = {}
Level.__index = Level

function Level.new(tmx)
	local level = {}
    setmetatable(level, Level)

    level.character = character
    level.tmx = tmx
    level.map = load_tileset(tmx)
    level.map.useSpriteBatch = true
    level.map.drawObjects = false
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)
    level.soundtrack = getSoundtrack(level.map)



    local player = Player.new(level.collider)
    player.boundary = {width=level.map.width * level.map.tileWidth}

    level.nodes = {}

    for k,v in pairs(level.map.objectLayers.nodes.objects) do
        if v.type == 'entrance' then
            player.position = {x=v.x, y=v.y}
        else 
            node = load_node(v.type)
            if node then
                table.insert(level.nodes, node.new(v, level.collider))
            end
        end
    end

    if level.map.objectLayers.floor then
        for k,v in pairs(level.map.objectLayers.floor.objects) do
            local floor = Floor.new(v, level.collider)
        end
    end

    if level.map.objectLayers.wall then
        for k,v in pairs(level.map.objectLayers.wall.objects) do
            local floor = Wall.new(v, level.collider)
        end
    end

    level.player = player

    return level
end

function Level:enter(previous, character)
    camera.max.x = self.map.width * self.map.tileWidth - window.width

    setBackgroundColor(self.map)

    self.previous = previous
    character = character or previous.character

    love.audio.play(self.soundtrack)

    if character then
        self.character = character
        self.player:loadCharacter(self.character)
    end
end

function Level:init()
end

function Level:update(dt)
    self.player:update(dt)

    if self.player.position.y - self.player.height > self.map.height * self.map.tileHeight then
        Gamestate.switch(Level.new('studyroom.tmx'), self.character)
        return
    end

    for i,node in ipairs(self.nodes) do
        if node.update then node:update(dt, self.player) end
    end

    self.collider:update(dt)

    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tileWidth * 2.5
    camera:setPosition(math.max(x - window.width / 2, 0),
                       math.min(math.max(y, 0), self.offset))
    Timer.update(dt)
end

function Level:draw()
    self.map:autoDrawRange(camera.x * -1, camera.y, 1, 0)
    self.map:draw()

    for i,node in ipairs(self.nodes) do
        if node.draw then node:draw() end
    end

    self.player:draw()
end

function Level:leave()
    love.audio.stop()
end


function Level:keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        self.player.halfjumpQueue:push('jump')
    end
end

function Level:keypressed(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        self.player.jumpQueue:push('jump')
    end

    for i,node in ipairs(self.nodes) do
        if node.player_touched and node.keypressed then node:keypressed(key) end
    end

    if key == 'escape' then
        Gamestate.switch('pause')
        return
    end
end

return Level
