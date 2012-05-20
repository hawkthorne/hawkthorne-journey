local menu = {}

tween = require 'vendor/tween'

function menu.load()
    love.audio.stop()

    cityscape = love.graphics.newImage("images/cityscape.jpg")
    logo = love.graphics.newImage("images/logo.png")
    logo_position = {y=-logo:getHeight()}

    font = love.graphics.newFont("fonts/xen3.ttf", 32)
    love.graphics.setFont(font)

    music = love.audio.newSource("audio/opening.ogg")
    music:setLooping(true)
    love.audio.play(music)

    tween(4, logo_position, { y=logo:getHeight() / 2 + 100})
end

function menu.update(dt)
    tween.update(dt)
end

function menu.keypressed(key)
    if key == "return" then
        return 'game'
    end
end

function menu.keyreleased(key)
end


function menu.draw()
    love.graphics.draw(cityscape)
    love.graphics.draw(logo, love.graphics:getWidth() / 2 - logo:getWidth()/2,
        love.graphics:getHeight() / 2 - logo_position.y)
    love.graphics.printf('PRESS ENTER', 0,
        love.graphics:getHeight() / 2 - logo_position.y + logo:getHeight() + 50,
        800, 'center')
end


return menu
