local Gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local character_state = require 'select'
local window = require 'window'
local menu = Gamestate.new()


function menu:init()
    love.audio.stop()

    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")
    self.button = love.graphics.newImage("images/enter.png")
    self.logo_position = {y=-self.logo:getHeight()}

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
        Gamestate.switch(character_state)
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
        window.height / 2 - self.logo_position.y)
    love.graphics.draw(self.button, window.width / 2 - self.button:getWidth()/2,
        window.height / 2 - self.logo_position.y + self.logo:getHeight() + 10)
end


return menu
