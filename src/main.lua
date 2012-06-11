local player = require 'player'
local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local camera = require 'camera'
local scale = 2
local paused = false
local atl = require 'vendor/AdvTiledLoader'

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true


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

    -- level loading
    Gamestate.load('studyroom', Level.new('studyroom.tmx'))
    Gamestate.load('hallway', Level.new('hallway.tmx'))
    Gamestate.load('forest', Level.new('forest2.tmx'))
    Gamestate.load('town', Level.new('town.tmx'))
    Gamestate.load('tavern', Level.new('tavern.tmx'))

    Gamestate.load('overworld', require 'overworld')
    Gamestate.load('home', require 'menu')
    Gamestate.load('pause', require 'pause')
    Gamestate.load('endscreen', require 'endscreen')

    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(1 / scale , 1 / scale)
    love.graphics.setMode(love.graphics:getWidth() * scale,
                          love.graphics:getHeight() * scale)

    local font = love.graphics.newImage("imagefont.png")
    font:setFilter('nearest', 'nearest')

    love.graphics.setFont(love.graphics.newImageFont(font,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/:;%&`'*#=\""), 35)

    Gamestate.switch('home')
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
    love.graphics.print(player:whatscore() .. ' Dollars', 10, 180)
end

