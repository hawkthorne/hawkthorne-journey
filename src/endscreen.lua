local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()
local logo = love.graphics.newImage("images/logo.png")

function state:init()
end

function state:enter(previous)
    sound.playMusic( "audio/ending.ogg" )
    camera:setPosition(0, 0)
end

function state:keypressed(key)
    if key == 'return' or key == 'esc' or key == ' ' then
        camera:setPosition(0, 0)
        Gamestate.switch(Gamestate.home)
    end
end

function state:leave()
end

function state:draw()
    camera:setPosition(0, 0)

    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(logo, window.width / 2 - logo:getWidth() / 4, 
                       75, 0, .5, .5)
    love.graphics.printf("That's the end of the demo", 0, 20, window.width, 'center')
    love.graphics.printf('Thanks for playing!', 0, 45, window.width, 'center')

    love.graphics.printf('Visit', 0, 175, window.width, 'center')

    love.graphics.setColor(255, 187, 93)
    love.graphics.printf('projecthawkthorne.com', 0, 200, window.width, 'center')
    love.graphics.setColor(255, 255, 255)

    love.graphics.printf('for more information', 0, 225,
                         window.width, 'center')
end


return state

