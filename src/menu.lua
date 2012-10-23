local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local menu = Gamestate.new()
local camera = require 'camera'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'

function menu:init()
    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")
    self.menu = love.graphics.newImage("images/openingmenu.png")
    self.arrow = love.graphics.newImage("images/small_arrow.png")
    self.logo_position = {y=-self.logo:getHeight()}
    self.logo_position_final = self.logo:getHeight() / 2 + 40
    tween(4, self.logo_position, { y=self.logo_position_final})

    self.options = {
        --  Displayed name            Action
        {'start',                'select'},
        {'instructions',        'instructions'},
        {'options',                'options'},
        {'credits',                'credits'},
        {'exit',                 'exit'},
    }
    self.selection = 0
    -- 'time_scale' is used to speed up the animation of the logo + menu
    self.time_scale = 1
end

function menu:enter()
    fonts.set( 'big' )
    camera:setPosition(0, 0)
    self.bg = sound.playMusic( "opening" )
end

function menu:update(dt)
    tween.update(dt * self.time_scale)
end

function menu:leave()
    fonts.reset()
    -- sound.stop(self.bg)
end

function menu:keypressed( button )
    if self.logo_position.y < self.logo_position_final then
        self.time_scale = 40
    else
        if button == "SELECT" or button == 'A' then
            local option = self.options[self.selection + 1][2]
            if option == 'exit' then
                love.event.push("quit")
            else
                Gamestate.switch(option)
            end
        elseif button == "UP" then
            self.selection = (self.selection - 1) % #self.options
        elseif button == "DOWN" then
            self.selection = (self.selection + 1) % #self.options
        end
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
    window.height / 2 - self.logo_position.y)

    local x = window.width / 2 - self.menu:getWidth()/2
    local y = window.height / 2 + self.logo:getHeight() - self.logo_position.y + 5
    love.graphics.draw(self.menu, x, y)

    for n,option in ipairs(self.options) do
        love.graphics.print(option[1], x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end

    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.selection - 1))

end

return menu
