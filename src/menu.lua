local Gamestate = require 'vendor/gamestate'
local character_state = require 'select'
local window = require 'window'
local menu = Gamestate.new()


function menu:init()
    love.audio.stop()

    self.cityscape = love.graphics.newImage("images/cityscape.png")
    self.logo = love.graphics.newImage("images/logo.png")

    local font = love.graphics.newImage("imagefont.png")
    font:setFilter('nearest', 'nearest')

    love.graphics.setFont(love.graphics.newImageFont(font,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/:;%&`'*#=\""), 35)

    local music = love.audio.newSource("audio/opening.ogg")
    music:setLooping(true)
    love.audio.play(music)
end

function menu:update(dt)
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(character_state)
    end
end

function menu:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
        window.height / 2 - self.logo:getHeight() / 2)
    love.graphics.printf("Press Enter", 0,
        window.height / 2 - self.logo:getHeight() / 2+ self.logo:getHeight() + 10,
        window.width, 'center')
end


return menu
