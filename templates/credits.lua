local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()

function state:init()
end

function state:enter(previous)
    fonts.set( 'big' )
    love.graphics.setBackgroundColor(0, 0, 0)
    sound.playMusic( "credits" )
    self.ty = 0
    camera:setPosition(0, self.ty)
    self.previous = previous
end

function state:leave()
    fonts.reset()
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

state.credits = {
    app.i18n('credits'),
    {% for contributor in contributors -%}
    '{{contributor}}',
    {% endfor %}
}

function state:draw()
    local shift = math.floor(self.ty/25)
    for i = shift - 11, shift + 1 do
        local name = self.credits[i]
        if name then
            love.graphics.printf(name, 0, 250 + 25 * i, window.width, 'center')
        end
    end
end

return state


