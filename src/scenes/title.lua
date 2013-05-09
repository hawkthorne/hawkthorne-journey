local core = require 'hawk/core'

local Title = core.Scene:subclass('Title')

function Title:initialize()
    self.cityscape = love.graphics.newImage("images/menu/cityscape.png")
    self.logo = love.graphics.newImage("images/menu/logo.png")
    self.splash = love.graphics.newImage("images/openingmenu.png")
    self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
end

function Title:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo)
end

return Title
