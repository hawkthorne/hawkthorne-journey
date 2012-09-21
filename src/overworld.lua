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

local wheelchair = love.graphics.newImage('images/free_ride_ferry.png')
local wc_x1, wc_x2, wc_y1, wc_y2 = 1685, 1956, 816, 680
local offset_x, offset_y = math.floor( wheelchair:getHeight() / 2 ) - 10, math.floor( wheelchair:getWidth() / 2 )

local g = anim8.newGrid(25, 31, worldsprite:getWidth(), 
    worldsprite:getHeight())
 
-- overworld state machine
state.zones = {
    forest_1={x=66, y=100, right='forest_2', level='studyroom'},
    forest_2={x=91, y=100, up='forest_3', left='forest_1', level='forest'},
    forest_3={x=91, y=89, up='town_1', down='forest_2', level='forest2'},
    forest_4={x=122, y=36, up='forest_5', left='island_4'},
    forest_5={x=122, y=22, down='forest_4'},
    town_1={x=91, y=76, left='town_2', down='forest_3', level='town'},
    town_2={x=71, y=76, left='town_3', right='town_1', level='town'},
    town_3={x=51, y=76, right='town_2', level='town', left='town_4'},
    town_4={x=37, y=76, right='town_3', up='valley_1', level='village-forest'},
    valley_1={x=37, y=45, right='valley_2', down='town_4', level='valley'},
    valley_2={x=66, y=45, up='valley_3', left='valley_1',
        bypass={right='up', down='left'}},
    valley_3={x=66, y=36, right='island_1', down='valley_2',
        bypass={up='right', left='down'}},
    island_1={x=93, y=36, left='valley_3', down='island_2',
        bypass={right='down', up='left'}},
    island_2={x=93, y=56, right='island_3', up='island_1', level='gay-island'},
    island_3={x=109, y=56, up='island_4', down='island_5', left='island_2', level='gay-island2'},
    island_4={x=109, y=36, right='forest_4', down='island_3',
        bypass={up='right', left='down'}},
    island_5={x=109, y=68, up='island_3', right='ferry'},
    ferry={x=163, y=68, up='caverns', left='island_5', name='Free Ride Ferry',
        bypass={down='left',right='up'}},
    caverns={x=163, y=44, down='ferry', level='black-caverns'},
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
        self.walk = anim8.newAnimation('loop', g(character.ow,2,character.ow,3), 0.5)
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
    if self.zone.name then
        return self.zone.name
    elseif self.zone.level == nil then
        return "UNCHARTED"
    end

    local level = Gamestate.get(self.zone.level)
    return level.title
end

function state:draw()
    love.graphics.setBackgroundColor(133, 185, 250)

    for i, image in ipairs(overworld) do
        local x = (i - 1) % 4
        local y = i > 4 and 1 or 0
        love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
    end

    if self.moving then
        self.walk:draw(worldsprite, math.floor(self.tx), math.floor(self.ty) - 15)
    else
        self.stand:draw(worldsprite, math.floor(self.tx), math.floor(self.ty) - 15)
    end

    for i, image in ipairs(overlay) do
        if image then
            local x = (i - 1) % 4
            local y = i > 4 and 1 or 0
            love.graphics.draw(image, x * image:getWidth(), y * image:getHeight())
        end
    end

    love.graphics.draw(board, camera.x + window.width - board:getWidth() / 2,
                              camera.y + window.height + board:getHeight() * 2)

    love.graphics.printf(self:title(),
                         camera.x + window.width - board:getWidth() / 2,
                         camera.y + window.height + board:getHeight() * 2.5 - 10,
                         board:getWidth(), 'center')

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
end


return state
