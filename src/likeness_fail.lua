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
  self.error = love.graphics.newImage("images/error.png")   --121x172
  self.errorMessage = false
  self.smile = false
  Timer.add(1, function()
    	self.smile = true
  end)
  Timer.add(3, function()
    self.flash = 1
    Timer.add(.05, function()
      self.flash = 0
      Timer.add(.05, function()
        self.flash = 1
          Timer.add(.05, function()
            self.flash = 0
            self.errorMessage = true
          end)
      end)
    end)
    Timer.add(4, function()
      Gamestate.switch('scanning')
    end)
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
  if self.errorMessage == false then
    love.graphics.draw(self.camera, ((window.width - 150)/2), ((window.height - 120)/2))
    love.graphics.setColor( 255, 255, 255, 255 )
    local warn1 = 'A photograph of you will be taken and  \n\n an avatar made of your likeness.'
    local offset1 = (window.width - love.graphics.getFont():getWidth(warn1))/2
    love.graphics.print(warn1, offset1, top + 36)
    local warn2 = 'Don\'t smile.'
    local offset2 = (window.width - love.graphics.getFont():getWidth(warn2))/2
    if self.smile then
    	love.graphics.print(warn2, offset2, top + 272)
	end
    if self.flash == 1 then
      love.graphics.rectangle("fill", 0, 0, window.width, window.height )
    end
  else
    love.graphics.draw(self.error, ((window.width - 121)/2), ((window.height - 172)/2))
    local warn3 = 'Error 60105'
    local offset3 = (window.width - love.graphics.getFont():getWidth(warn3))/2
    love.graphics.print(warn3, offset3, top + 36)
    local warn4 = 'Defaulting to preloaded avitar...'
    local offset4 = (window.width - love.graphics.getFont():getWidth(warn4))/2
    love.graphics.print(warn4, offset4, top + 272)
  end

end

function autosave_warning:keypressed(button)
  Timer.clear()
  Gamestate.switch('scanning')
end

function autosave_warning:update(dt)
  VerticalParticles.update(dt)
end

return autosave_warning
