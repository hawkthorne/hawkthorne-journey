local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local VerticalParticles = require "verticalparticles"

local autosave_warning = Gamestate.new()

local savingImage = love.graphics.newImage('images/hud/saving.png')
savingImage:setFilter('nearest', 'nearest')

function autosave_warning:init( )
    VerticalParticles.init()
end

function autosave_warning:enter( prev )

  local h = anim8.newGrid(36, 36, savingImage:getWidth(), savingImage:getHeight())
  self.savingAnimation = anim8.newAnimation('loop', h('1-8,1'), .25)
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
  local top = (window.height - 36)/2 
  local side = (window.width - 36)/2
  self.savingAnimation:draw(savingImage, side, top)
  love.graphics.setColor( 255, 255, 255, 255 )
  local warn1 = 'This game utilizes an autosave feature.'
  local offset1 = (window.width - love.graphics.getFont():getWidth(warn1))/2
  love.graphics.print(warn1, offset1, top + 36)
  local warn2 = 'It will run each time you reach a new level or checkpoint.'
  local offset2 = (window.width - love.graphics.getFont():getWidth(warn2))/2
  love.graphics.print(warn2, offset2, top + 54)
  local warn3 = 'You can also manually save in the options if ever you\'re in a hurry.'
  local offset3 = (window.width - love.graphics.getFont():getWidth(warn3))/2
  love.graphics.print(warn3, offset3, top + 72)

end

function autosave_warning:keypressed(button)
  Timer.clear()
  Gamestate.switch('scanning')
end

function autosave_warning:update(dt)
  VerticalParticles.update(dt)
  self.savingAnimation:update(dt)
end

return autosave_warning
