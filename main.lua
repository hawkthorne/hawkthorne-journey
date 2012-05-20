menu = require 'menu'
game = require 'game'

states = {
    ['menu']=menu,
    ['game']=game,
}

state = game

function love.load()
    state.load()
end

function love.update(dt)
    state.update(dt)
end

function love.keyreleased(key)
    state.keyreleased(key)
end


function love.keypressed(key)
    next_state = state.keypressed(key)

    if next_state then
        state = states[next_state]
        state.load()
    end
end

function love.draw()
    state.draw()
end

