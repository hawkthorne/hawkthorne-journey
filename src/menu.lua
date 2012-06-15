local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local menu = Gamestate.new()
local camera = require 'camera'
local tween = require 'vendor/tween'

function menu:init()
    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")
    self.menu = love.graphics.newImage("images/openingmenu.png")
    self.arrow = love.graphics.newImage("images/small_arrow.png")
    self.logo_position = {y=-self.logo:getHeight()}
    tween(4, self.logo_position, { y=self.logo:getHeight() / 2 + 40})

    self.options = {'select', 'instructions', 'credits'}
    self.selection = 0
end

function menu:enter()
    camera:setPosition(0, 0)
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
        Gamestate.switch(self.options[self.selection + 1])
    elseif key == 'up' or key == 'w' then
        self.selection = (self.selection - 1) % 3
    elseif key == 'down' or key == 's' then
        self.selection = (self.selection + 1) % 3
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
        window.height / 2 - self.logo_position.y)

    love.graphics.draw(self.menu, window.width / 2 - self.menu:getWidth()/2,
        window.height / 2 + self.logo:getHeight() - self.logo_position.y + 20)
    love.graphics.draw(self.arrow, 190, window.height / 2 + self.logo:getHeight() - self.logo_position.y + 42 + 12 * (self.selection - 1))

end

return menu
