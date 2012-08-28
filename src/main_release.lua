local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local camera = require 'camera'
local paused = false
local atl = require 'vendor/AdvTiledLoader'
local sound = require 'vendor/TEsound'

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

-- will hold the currently playing sources

function love.load()
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    local width = love.graphics:getWidth()
    local height = love.graphics:getHeight()
    camera:setScale(456 / width , 264 / height)
    love.graphics.setMode(width, height)

    local font = love.graphics.newImage("imagefont.png")
    font:setFilter('nearest', 'nearest')

    love.graphics.setFont(love.graphics.newImageFont(font,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/:;%&`'*#=\""), 35)

    Gamestate.switch(require('loader'))
end

function love.update(dt)
    if paused then return end
    dt = math.min(0.033333333, dt)
    Gamestate.update(dt)
    sound.cleanup()
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end

function love.focus(f)
    paused = not f
	if not f then 
        sound.pause('music')
        sound.pause('sfx')
    else
        sound.resume('music')
        sound.resume('sfx')
    end
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

