local Gamestate = require 'vendor/gamestate'
local menu = require 'menu'

function love.load()
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
    Gamestate.draw()
end

