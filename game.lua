local anim8 = require 'vendor/anim8'

local game = {}

function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")

    sheet = love.graphics.newImage("images/abed_sheet.png")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

    local g = anim8.newGrid(92, 92, sheet:getWidth(), sheet:getHeight())

    animations = {
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }

    direction = 'right'
    pos = {x=300, y=450}
    walking = false
    reset = true
end

function game.currentAnimation()
    if walking then 
        return animations['walk'][direction]
    else
        return animations['idle'][direction]
    end
end

function game.update(dt)
    if love.keyboard.isDown("left") then
        direction = 'left'
        pos.x = pos.x - 2
    elseif love.keyboard.isDown("right") then
        direction = 'right'
        pos.x = pos.x + 2
    end

    if walking and reset then
        game.currentAnimation():gotoFrame(1)
        reset = false
    else
        game.currentAnimation():update(dt)
    end
end

function game.keyreleased(key)
    if (key == "left" or key == "right") then
        walking = false
    end
end

function game.keypressed(key)
    if (key == "left" or key == "right") then
        walking = true
        reset = true
    end
end


function game.draw()
    love.graphics.draw(bg)
    game.currentAnimation():draw(sheet, pos.x, pos.y)
end


return game
