----MUST READ:
--this is a template gamestate that simply
-- prints "hello world" and plays music

local Gamestate = require 'vendor/gamestate'
local fonts = require 'fonts'
local window = require 'window'
local sound = require 'vendor/TEsound'

--instantiate this gamestate
local state = Gamestate.new()

--called once when the gamestate is initialized
function state:init()
end

--called when the player enters this gamestate
--enter may take additional arguments from previous as necessary
--@param previous the actual gamestate that the player came from (not just its name)
function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )
    self.previous = previous
end

--called when this gamestate receives a keypress event
--@param button the button that was pressed
function state:keypressed( button )
    --exit when you press START
    if button == "START" then
        Gamestate.switch(self.previous)
    end
end

--called when this gamestate receives a keyrelease event
--@param button the button that was released
function state:keyreleased( button )
end

--called when the player leaves this gamestate
function state:leave()
end

--called when love draws this gamestate
function state:draw()
    local width = window.width
    local height = window.height
    love.graphics.setColor(255,0,0,255)
    love.graphics.rectangle('fill', 0, 0, width, height)
    local x = 0
    local y = height/2
    love.graphics.setColor(0, 255, 255, 255)
    love.graphics.printf('HELLO WORLD!', 0, height/2, width, 'center')
end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state
