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
  camera:setPosition(0, 0)
end

function state:update(dt)
  self.ty = self.ty + 50 * dt
  camera:setPosition(0, self.ty)
  if self.ty > ( #self.credits * 25 ) + 500 then
    Gamestate.switch(self.previous)
  end
end

function state:keypressed( button )
  if button == 'UP' then
    self.ty = math.max( self.ty - 100, 300 )
  elseif button == 'DOWN' then
    self.ty = math.min( self.ty + 100, ( #self.credits * 25 ) + 30 )
  else
    Gamestate.switch(self.previous)
  end
end

state.credits = {
  app.i18n('credits'), '',
  {% for contributor in contributors -%}
  '{{contributor}}',
  {% endfor -%}
}

function state:draw()
  local shift = math.floor(self.ty/25)
  for i = shift - 14, shift + 1 do
    local name = self.credits[i]
    if name then
      love.graphics.printf(name, 0, window.height + 25 * i, window.width, 'center')
    end
  end
end

return state
