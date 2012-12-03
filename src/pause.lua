local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()
local VerticalParticles = require "verticalparticles"


function state:init()
    VerticalParticles.init()
    self.arrow = love.graphics.newImage("images/menu/arrow.png")
    self.background = love.graphics.newImage("images/menu/pause.png")
end

function state:enter(previous)
    love.graphics.setBackgroundColor(0, 0, 0)

    self.music = sound.playMusic( "daybreak" )

    fonts.set( 'big' )

    camera:setPosition(0, 0)
    self.option = 0
    
    if previous ~= Gamestate.get('options') then
        self.previous = previous
    end
    
    self.konami = { 'UP', 'UP', 'DOWN', 'DOWN', 'LEFT', 'RIGHT', 'LEFT', 'RIGHT', 'JUMP', 'ACTION' }
    self.konami_idx = 0
end

function state:update(dt)
    VerticalParticles.update(dt)
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    if button == "UP" then
        self.option = (self.option - 1) % 5
    elseif button == "DOWN" then
        self.option = (self.option + 1) % 5
    end

    if button == "START" then
        Gamestate.switch(self.previous)
        return
    end
    
    if button == "ACTION" or button == "SELECT" then
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

    if self.konami[self.konami_idx + 1] == button then
        self.konami_idx = self.konami_idx + 1
    else
        self.konami_idx = 0
    end
    
    if self.konami_idx == #self.konami then
        Gamestate.switch('cheatscreen', self.previous )
    end
end

function state:draw()
    VerticalParticles.draw()

    love.graphics.draw(self.background, 
      camera:getWidth() / 2 - self.background:getWidth() / 2,
      camera:getHeight() / 2 - self.background:getHeight() / 2)

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.print('Resume', 198, 101)
    love.graphics.print('Options', 198, 131)
    love.graphics.print('Quit to Map', 198, 161)
    love.graphics.print('Quit to Menu', 198, 191)
    love.graphics.print('Quit to Desktop', 198, 221)
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw(self.arrow, 156, 96 + 30 * self.option)
end


return state

