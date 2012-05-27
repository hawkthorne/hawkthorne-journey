local Gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local menu = require 'menu'
local scale = 2

function love.load()
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    camera:setScale(1 / scale , 1 / scale)
    love.graphics.setMode(love.graphics:getWidth() * scale,
                          love.graphics:getHeight() * scale)
    Gamestate.switch(menu)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.keyreleased(key)
    Gamestate.keyreleased(key)
end


function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.draw()
    camera:set()
    Gamestate.draw()
    camera:unset()
end

