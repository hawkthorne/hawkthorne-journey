local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()


function state:init()
    self.arrow = love.graphics.newImage("images/arrow.png")
    self.background = love.graphics.newImage("images/pause.png")
end

function state:enter(previous)
    self.music = sound.playMusic( "daybreak" )

    fonts.set( 'big' )

    camera:setPosition(0, 0)
    self.option = 0
    
    if previous ~= Gamestate.get('options') then
        self.previous = previous
    end
    
    self.konami = { 'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a' }
    self.konami_idx = 0
end

function state:leave()
    fonts.reset()
end

function state:keypressed(key)
    if key == 'up' or key == 'w' then
        self.option = (self.option - 1) % 5
    elseif key == 'down' or key == 's' then
        self.option = (self.option + 1) % 5
    end

    if key == 'escape' then
        Gamestate.switch(self.previous)
        return
    end
    
    if key == 'return' or key == 'kpenter' then
        if self.option == 0 then
            Gamestate.switch(self.previous)
        elseif self.option == 1 then
            Gamestate.switch('options')
        elseif self.option == 2 then
            Gamestate.switch('overworld')
        elseif self.option == 3 then
            self.previous:quit()
            Gamestate.switch(Gamestate.home)
        elseif self.option == 4 then
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
    love.graphics.print('Resume', 198, 101)
    love.graphics.print('Options', 198, 131)
    love.graphics.print('Quit to Map', 198, 161)
    love.graphics.print('Quit to Menu', 198, 191)
    love.graphics.print('Quit to Desktop', 198, 221)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.arrow, 156, 96 + 30 * self.option)
end


return state

