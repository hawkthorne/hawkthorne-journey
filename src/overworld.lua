local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local atl = require 'vendor/AdvTiledLoader'
local window = require 'window'
local camera = require 'camera'
local state = Gamestate.new()

local map = {}
map.tileWidth = 12
map.tileHeight = 12
map.width = 193
map.height = 111

local scale = 2

local overworld = {
    town = love.graphics.newImage('images/overworld_town.png'),
    trees = love.graphics.newImage('images/overworld_trees.png'),
    forest = love.graphics.newImage('images/overworld_forest.png'),
    forestpath = love.graphics.newImage('images/overworld_forestpath.png'),
}

local board = love.graphics.newImage('images/titleboard.png')

local worldsprite = love.graphics.newImage('images/overworld.png')

local g = anim8.newGrid(25, 31, worldsprite:getWidth(), 
    worldsprite:getHeight())

local background = love.audio.newSource("audio/level.ogg")
background:setLooping(true)
 
-- overworld state machine
state.zones = {
    forest_1={x=66, y=100, right='forest_2', level='studyroom'},
    forest_2={x=91, y=100, up='forest_3', left='forest_1', level='forest'},
    forest_3={x=91, y=89, up='town_1', down='forest_2', level='forest'},
    forest_4={x=65, y=16, up='forest_5', left='island_4'},
    forest_5={x=65, y=7, down='forest_4'},
    town_1={x=91, y=76, left='town_2', down='forest_3', level='town'},
    town_2={x=71, y=76, left='town_3', right='town_1', level='town'},
    town_3={x=51, y=76, right='town_2', level='town'}, -- left=town_4
    town_4={x=37, y=76, right='town_3', level='town', up='valley_1'},
    valley_1={x=14, y=22, right='valley_2', down='town_4'},
    valley_2={x=34, y=22, up='valley_3', left='valley_1',
        bypass={right='up', down='left'}},
    valley_3={x=34, y=16, right='island_1', down='valley_2',
        bypass={up='right', left='down'}},
    island_1={x=47, y=16, left='valley_3', down='island_2',
        bypass={right='down', up='left'}},
    island_2={x=47, y=28, right='island_3', up='island_1'},
    island_3={x=57, y=28, up='island_4', down='island_5', left='island_2'},
    island_4={x=57, y=16, right='forest_4', down='island_3',
        bypass={up='right', left='down'}},
    island_5={x=57, y=37, up='island_3', right='ferry'},
    ferry={x=88, y=37, up='caverns', left='island_5'},
    caverns={x=88, y=24, down='ferry'},
}


function state:init()
    self.tide = false
    self:reset()
end

function state:enter(previous, character)
    camera:scale(scale, scale)
    camera.max.x = map.width * map.tileWidth - (window.width * 2)

    character = character or previous.character

    love.audio.play(background)

    if character then
        self.character = character
        self.stand = anim8.newAnimation('once', g(character.ow, 1), 1)
        self.walk = anim8.newAnimation('loop', g(character.ow,2,character.ow,3), 0.5)
    end

    self:reset()
end

function state:leave()
    love.audio.stop(background)
    camera:scale(.5, .5)
end

function state:reset()
    self.zone = self.zones['forest_1']
    self.tx = self.zone.x * map.tileWidth --self.zone.x * map.tileWidth
    self.ty = self.zone.y * map.tileHeight --self.zone.y * map.tileWidth
    self.vx = 0
    self.vy = 0
    self.moving = false
    self.entered = false
end

function state:update(dt)
    if self.moving then
        self.walk:update(dt)
    end

    self.walk:update(dt)
    local dy = self.vy * dt * 300
    local dx = self.vx * dt * 300
    self.tx = self.tx + dx
    self.ty = self.ty + dy

    if math.abs(self.tx - self.zone.x * map.tileWidth) <= math.abs(dx) and 
        math.abs(self.ty - self.zone.y * map.tileHeight) <= math.abs(dy) then
        self.tx = self.zone.x * map.tileWidth
        self.ty = self.zone.y * map.tileHeight
        self.vx = 0
        self.vy = 0

        if self.entered and self.zone.bypass then
            self:move(self.zone.bypass[self.entered])
        else
            self.moving = false
            self.entered = false
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
        self.zone = self.zones[self.zone.up]
        self.moving = 'up'
        self.vx = 0
        self.vy = -1
        self.entered = key
    elseif key == 'down' and self.zone.down then
        self.zone = self.zones[self.zone.down]
        self.moving = 'down'
        self.vx = 0
        self.vy = 1
        self.entered = key
    elseif key == 'left' and self.zone.left then
        self.zone = self.zones[self.zone.left]
        self.moving = 'left'
        self.vx = -1
        self.vy = 0
        self.entered = key
    elseif key == 'right' and self.zone.right then
        self.zone = self.zones[self.zone.right]
        self.moving = 'right'
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

    if key == 'return' then
        local level = Gamestate.get(self.zone.level)
        Gamestate.load(self.zone.level, level.new(level.tmx))
        Gamestate.switch(self.zone.level, self.character)
    end

    if mapping[key] then
        key = mapping[key]
    end

    self:move(key)
end


function state:draw()
    love.graphics.setBackgroundColor(133, 185, 250)

    love.graphics.draw(overworld.town, 38 * map.tileWidth, 61 * map.tileHeight)
    love.graphics.draw(overworld.trees, 0, 79 * map.tileHeight)
    love.graphics.draw(overworld.forestpath, 61 * map.tileWidth, 81 * map.tileHeight)

    if self.moving then
        self.walk:draw(worldsprite, math.floor(self.tx), math.floor(self.ty) - 15)
    else
        self.stand:draw(worldsprite, math.floor(self.tx), math.floor(self.ty) - 15)
    end

    love.graphics.draw(overworld.forest, 61 * map.tileWidth, 81 * map.tileHeight)

    love.graphics.draw(board, camera.x + window.width - board:getWidth() / 2,
                              camera.y + window.height + board:getHeight() * 2)

    love.graphics.printf(self.zone.level,
                         camera.x + window.width - board:getWidth() / 2,
                         camera.y + window.height + board:getHeight() * 2.5 - 10,
                         board:getWidth(), 'center')

end


return state
