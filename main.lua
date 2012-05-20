tween = require 'vendor/tween'

function love.load()
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

function love.update(dt)
    tween.update(dt)
end

function love.keypressed(key)
    if key == "return" then
        love.event.push("quit")
    end
end

function love.draw()
    love.graphics.draw(cityscape)
    love.graphics.draw(logo, love.graphics:getWidth() / 2 - logo:getWidth()/2,
        love.graphics:getHeight() / 2 - logo_position.y)
    love.graphics.printf('PRESS ENTER', 0,
        love.graphics:getHeight() / 2 - logo_position.y + logo:getHeight() + 50,
        800, 'center')
end

