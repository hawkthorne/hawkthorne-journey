local Gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local game = require 'game'
local menu = Gamestate.new()


function menu:init()
    love.audio.stop()

    self.cityscape = love.graphics.newImage("images/cityscape.jpg")
    self.logo = love.graphics.newImage("images/logo.png")
    self.logo_position = {y=-self.logo:getHeight()}

    love.graphics.setFont(love.graphics.newFont("fonts/xen3.ttf", 32))

    local music = love.audio.newSource("audio/opening.ogg")
    music:setLooping(true)
    love.audio.play(music)

    tween(4, self.logo_position, { y=self.logo:getHeight() / 2})
end

function menu:update(dt)
    tween.update(dt)
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(game)
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, love.graphics:getWidth() / 2 - self.logo:getWidth()/2,
        love.graphics:getHeight() / 2 - self.logo_position.y)
    love.graphics.printf('PRESS ENTER', 0,
        love.graphics:getHeight() / 2 - self.logo_position.y + self.logo:getHeight() + 50,
        love.graphics:getWidth(), 'center')
end


return menu
