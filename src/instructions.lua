local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local state = Gamestate.new()


function state:init()
    self.background = love.graphics.newImage("images/pause.png")
end

function state:enter(previous)
    self.music = love.audio.play("audio/daybreak.ogg", "stream", true)

    camera:setPosition(0, 0)
    self.previous = previous
end

function state:leave()
    love.audio.stop(self.music)
end

function state:keypressed(key)
    if key == 'escape' or key == 'return' then
        Gamestate.switch(self.previous)
        return
    end
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('UP', 110, 66)
    love.graphics.print('DOWN', 110, 93)
    love.graphics.print('LEFT', 110, 120)
    love.graphics.print('RIGHT', 110, 147)
    love.graphics.print('JUMP', 110, 174)
    love.graphics.print('- W / UP ARROW', 170, 66)
    love.graphics.print('- S / DOWN ARROW', 170, 93)
    love.graphics.print('- A / LEFT ARROW', 170, 120)
    love.graphics.print('- D / RIGHT ARROW', 170, 147)
    love.graphics.print('- SPACEBAR', 170, 174)
    love.graphics.setColor(255, 255, 255)
end


return state
