local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local splash = Gamestate.new()
local camera = require 'camera'
local menu = require 'menu'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'

function splash:init()
    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")
    self.splash = love.graphics.newImage("images/openingmenu.png")
    self.arrow = love.graphics.newImage("images/small_arrow.png")
    self.logo_position = {y=-self.logo:getHeight()}
    self.logo_position_final = self.logo:getHeight() / 2 + 40
    tween(4, self.logo_position, { y=self.logo_position_final})

    self.menu = menu.new({'start', 'instructions', 'options', 'credits', 'exit'})
    self.menu:onSelect(function(option)
            if option == 'exit' then
                love.event.push("quit")

              elseif option == 'start' then
                Gamestate.switch('select')
            else
                Gamestate.switch(option)
            end
    end)

    -- 'time_scale' is used to speed up the animation of the logo + splash
    self.time_scale = 1
end

function splash:enter(a)
    fonts.set( 'big' )
    camera:setPosition(0, 0)
    self.bg = sound.playMusic( "opening" )
end

function splash:update(dt)
    tween.update(dt * self.time_scale)
end

function splash:leave()
    fonts.reset()
    -- sound.stop(self.bg)
end

function splash:keypressed( button )
    if self.logo_position.y < self.logo_position_final then
        self.time_scale = 40
    else
        self.menu:keypressed(button) 
    end
end

function splash:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
    window.height / 2 - self.logo_position.y)

    local x = window.width / 2 - self.splash:getWidth()/2
    local y = window.height / 2 + self.logo:getHeight() - self.logo_position.y + 5
    love.graphics.draw(self.splash, x, y)

    for n,option in ipairs(self.menu.options) do
        love.graphics.print(option, x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end

    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))

end

return splash
