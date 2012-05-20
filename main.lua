function love.load()
    music = love.audio.newSource("audio/opening.ogg")
    music:setLooping(true)
    love.audio.play(music)
end

function love.draw()
    love.graphics.print("Hello World", 400, 300)
end

