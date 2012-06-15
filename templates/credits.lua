local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
end

function state:enter(previous)
    love.graphics.setBackgroundColor(0, 0, 0)
    self.music = love.audio.play("audio/credits.ogg", "stream", true)
    self.ty = 0
    camera:setPosition(0, self.ty)
    self.previous = previous
end

function state:leave()
    love.audio.stop(self.music)
end

function state:update(dt)
    self.ty = self.ty + 50 * dt
    camera:setPosition(0, self.ty)
end

function state:keypressed(key)
    if key == 'escape' or key == 'return' then
        Gamestate.switch(self.previous)
    end
end

function state:draw()
    love.graphics.printf('CREDITS', 0, 275, window.width, 'center')
    {% for contributor in contributors -%}
    love.graphics.printf('{{contributor}}', 0, {{loop.index * 25 + 275}}, window.width, 'center')
    {% endfor %}
end

return state


