local Gamestate = require 'vendor/gamestate'
local Queue = require 'queue'
local anim8 = require 'vendor/anim8'
local tmx = require 'vendor/tmx'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local window = require 'window'
local sound = require 'vendor/TEsound'
local music = {}

local node_cache = {}
local tile_cache = {}

local Player = require 'player'
local Floor = require 'nodes/floor'
local Platform = require 'nodes/platform'
local Wall = require 'nodes/wall'

function load_tileset(name)
    if tile_cache[name] then
        return tile_cache[name]
    end
    
    local tileset = tmx.load(require("maps/" .. name))
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

-- Return the default Abed character
function defaultCharacter()
    local abed = require 'characters/abed'
    return abed.new(love.graphics.newImage('images/abed.png'))
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

function Level.new(name)
    local level = {}
    setmetatable(level, Level)

    level.character = character
    level.over = false
    level.name = name
    level.map = require("maps/" .. name)
    level.background = load_tileset(name)
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)
    level.music = getSoundtrack(level.map)
    level.jumping = jumpingAllowed(level.map)
    level.spawn = 'studyroom'
    level.title = getTitle(level.map)
    level.character = defaultCharacter()

    local player = Player.new(level.collider)
    player:loadCharacter(level.character)
    player.boundary = {width=level.map.width * level.map.tilewidth}

    level.nodes = {}

    for k,v in pairs(level.map.objectgroups.nodes.objects) do
        if v.type == 'floorspace' then --special cases are bad
            player.crouch_state = 'crouchwalk'
            player.gaze_state = 'gazewalk'
        end

        if v.type == 'entrance' then
            player.position = {x=v.x, y=v.y}
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
            local platform = Platform.new(v, level.collider)
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

function Level:enter(previous, character)
    camera.max.x = self.map.width * self.map.tilewidth - window.width

    setBackgroundColor(self.map)

    self.previous = previous
    sound.playMusic( self.music )

    if character then
        self.character = character
        self.player:loadCharacter(self.character)
        if getWarpIn(self.map) then
            self.player:respawn()
        end
    end
end

function Level:init()
end

function Level:update(dt)
    self.player:update(dt)

    if self.player.position.y - self.player.height > self.map.height * self.map.tileheight then
        self.player.health = 0
        self.player.state = 'dead'
    end

    if self.player.state == 'dead' and not self.over then
        sound.stopMusic()
        sound.playSfx( 'death' )
        self.over = true
        self.respawn = Timer.add(3, function() 
            Gamestate.get('overworld'):reset()
            Gamestate.switch(Level.new(self.spawn), self.character)
        end)
    end

    for i,node in ipairs(self.nodes) do
        if node.update then node:update(dt, self.player) end
    end

    self.collider:update(dt)

    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tilewidth * 2.5
    camera:setPosition(math.max(x - window.width / 2, 0),
                       math.min(math.max(y, 0), self.offset))
    Timer.update(dt)
end

function Level:quit()
    if self.respawn ~= nil then
        Timer.cancel(self.respawn)
    end
end

function Level:draw()
    self.background:draw(camera.x * -1, -camera.y)

    for i,node in ipairs(self.nodes) do
        if node.draw and not node.foreground then node:draw() end
    end

    self.player:draw()

    for i,node in ipairs(self.nodes) do
        if node.draw and node.foreground then node:draw() end
    end

end

function Level:leave()
end


function Level:keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and self.jumping then
        self.player.halfjumpQueue:push('jump')
    end
end

function Level:keypressed(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and self.jumping then
        self.player.jumpQueue:push('jump')
    end

    for i,node in ipairs(self.nodes) do
        if node.player_touched and node.keypressed then
            node:keypressed(key, self.player)
        end
    end

    if key == 'escape' and self.player.state ~= 'dead' then
        Gamestate.switch('pause')
        return
    end
end

return Level
