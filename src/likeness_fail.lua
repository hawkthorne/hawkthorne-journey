local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local VerticalParticles = require "verticalparticles"

local autosave_warning = Gamestate.new()



function autosave_warning:init( )
    VerticalParticles.init()
end

function autosave_warning:enter( prev )

  
  self.camera = love.graphics.newImage("images/camera.png")
  self.splash = love.graphics.newImage("images/cameramenu.png")
  Timer.add(8, function()
    Gamestate.switch('scanning')
  end)
end

function autosave_warning:leave()
  self.current = nil
end

function autosave_warning:draw()
  VerticalParticles.draw()
  love.graphics.setColor( 255, 255, 255, 255 )
  local top = (window.height - 300)/2 
  local side = (window.width - 400)/2
  love.graphics.draw(self.splash, side, top)
  love.graphics.draw(self.camera, ((window.width - 150)/2), ((window.height - 120)/2))
  love.graphics.setColor( 255, 255, 255, 255 )
  local warn1 = 'A photograph of you will be taken and  \n\n an avatar made of your likeness.'
  local offset1 = (window.width - love.graphics.getFont():getWidth(warn1))/2
  love.graphics.print(warn1, offset1, top + 36)
  --local warn2 = 'It will run each time you reach a new level or checkpoint.'
  --local offset2 = (window.width - love.graphics.getFont():getWidth(warn2))/2
  --love.graphics.print(warn2, offset2, top + 54)
  local warn3 = 'Don\'t smile.'
  local offset3 = (window.width - love.graphics.getFont():getWidth(warn3))/2
  love.graphics.print(warn3, offset3, top + 272)

end

function autosave_warning:keypressed(button)
  Timer.clear()
  Gamestate.switch('scanning')
end

function autosave_warning:update(dt)
  VerticalParticles.update(dt)
end

return autosave_warning
