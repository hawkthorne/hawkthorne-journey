local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local camera = require 'camera'
local menu = require 'menu'
local scale = 2
local paused = false

function love.load()

    -- costume loading
    love.filesystem.mkdir('costumes')
    love.filesystem.mkdir('costumes/troy')
    love.filesystem.mkdir('costumes/abed')
    love.filesystem.mkdir('costumes/annie')
    love.filesystem.mkdir('costumes/shirley')
    love.filesystem.mkdir('costumes/pierce')
    love.filesystem.mkdir('costumes/jeff')
    love.filesystem.mkdir('costumes/britta')

    -- tileset loading
    Level.load_tileset('studyroom.tmx')
    Level.load_tileset('hallway.tmx')
    Level.load_tileset('forest2.tmx')
    Level.load_tileset('town.tmx')

    -- load images
    Level.load_image('images/cow.png')
    Level.load_image('images/hippy.png')

    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(1 / scale , 1 / scale)
    love.graphics.setMode(love.graphics:getWidth() * scale,
                          love.graphics:getHeight() * scale)
    Gamestate.switch(menu)
end

function love.update(dt)
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end

function love.focus(f)
    paused = not f
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.draw()
    camera:set()
    Gamestate.draw()
    camera:unset()

    if paused then
        love.graphics.setColor(75, 75, 75, 125)
        love.graphics.rectangle('fill', 0, 0, love.graphics:getWidth(),
                                love.graphics:getHeight())
        love.graphics.setColor(255, 255, 255, 255)
    end

    love.graphics.print(love.timer.getFPS() .. ' FPS', 10, 10)
end

