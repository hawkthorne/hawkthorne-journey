local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()


function state:init()
    self.arrow = love.graphics.newImage("images/arrow.png")
    self.background = love.graphics.newImage("images/pause.png")
end

function state:enter(previous)
    self.music = sound.playMusic( "daybreak" )

    camera:setPosition(0, 0)
    self.option = 0
    self.previous = previous
	
	self.konami = { 'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a' }
	self.konami_idx = 0
end

function state:leave()
end

function state:keypressed(key)
    if key == 'up' or key == 'w' then
        self.option = (self.option - 1) % 4
    elseif key == 'down' or key == 's' then
        self.option = (self.option + 1) % 4
    end

    if key == 'escape' then
        Gamestate.switch(self.previous)
        return
    end
    
    if key == 'return' then
        if self.option == 0 then
            Gamestate.switch(self.previous)
        elseif self.option == 1 then
            Gamestate.switch('overworld')
        elseif self.option == 2 then
            self.previous:quit()
            Gamestate.switch(Gamestate.home)
        elseif self.option == 3 then
            love.event.push("quit")
        end
    end

    if self.konami[self.konami_idx + 1] == key then
        self.konami_idx = self.konami_idx + 1
    else
        self.konami_idx = 0
    end
    
    if self.konami_idx == #self.konami then
        Gamestate.switch('cheatscreen', self.previous )
    end
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('Resume', 162, 75)
    love.graphics.print('Quit to Map', 162, 105)
    love.graphics.print('Quit to Menu', 162, 135)
    love.graphics.print('Quit to Desktop', 162, 165)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.arrow, 120, 70 + 30 * self.option)
end


return state

