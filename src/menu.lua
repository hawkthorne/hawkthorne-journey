local Gamestate = require 'vendor/gamestate'
local character_state = require 'select'
local window = require 'window'
local menu = Gamestate.new()
local tween = require 'vendor/tween'

function menu:init()

    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")
    self.logo_position = {y=-self.logo:getHeight()}
    tween(4, self.logo_position, { y=self.logo:getHeight() / 2})
end

function menu:enter()
    self.bg = love.audio.play("audio/opening.ogg", "stream", true)
end

function menu:update(dt)
    tween.update(dt)
end

function menu:leave()
    love.audio.stop(self.bg)
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(character_state)
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
        window.height / 2 - self.logo_position.y)
    love.graphics.printf("Press Enter", 0,
        window.height / 2 - self.logo_position.y + self.logo:getHeight() + 10,
        window.width, 'center')
end

Gamestate.title = menu

return menu
