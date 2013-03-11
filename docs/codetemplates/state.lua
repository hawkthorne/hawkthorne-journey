local Gamestate = require 'vendor/gamestate'
local state = Gamestate.new()

--called once when the gammestate is initialized
function state:init()
end

--called when the player enters this gamestate
--enter may take additional arguments from previous as necessary
--@param previous the actual gamestate that the player came from (not just its name)
function state:enter(previous)
end

--called when this gamestate receives a keypress event
--@param button the button that was pressed
function state:keypressed( button )
end

--called when this gamestate receives a keyrelease event
--@param button the button that was released
function keyreleased( button )
end

--called when the player leaves this gamestate
function state:leave()
end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state