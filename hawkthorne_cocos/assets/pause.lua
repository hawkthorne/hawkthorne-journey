local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
    self.arrow = love.graphics.newImage("images/arrow.png")
    self.daybreak = love.audio.newSource("audio/daybreak.ogg")
    self.daybreak:setLooping(true)
    self.background = love.graphics.newImage("images/pause.png")
end

function state:enter(previous)
    love.audio.rewind(self.daybreak)
    love.audio.play(self.daybreak)

    camera:setPosition(0, 0)
    self.option = 0
    self.previous = previous
end

function state:leave()
    love.audio.stop()
end

function state:keypressed(key)
    if key == 'up' or key == 'w' then
        self.option = (self.option - 1) % 3
    elseif key == 'down' or key == 's' then
        self.option = (self.option + 1) % 3
    end

    if key == 'escape' then
        Gamestate.switch(self.previous)
        return
    end
    
    if key == 'return' then
        if self.option == 0 then
            Gamestate.switch(self.previous)
        elseif self.option == 1 then
            Gamestate.switch(Gamestate.home)
        elseif self.option == 2 then
            love.event.push("quit")
        end
    end
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.print('Resume', 162, 77)
    love.graphics.print('Quit to Menu', 162, 125)
    love.graphics.print('Quit to Desktop', 162, 173)
    love.graphics.draw(self.arrow, 120, 72 + 48 * self.option)
end


return state

