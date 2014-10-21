local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local VerticalParticles = require "verticalparticles"

local state = Gamestate.new()

function state:init()

  VerticalParticles.init()
  self.background = love.graphics.newImage("images/menu/pause.png")
  self.savingImage = love.graphics.newImage('images/menu/saving.png')
  
  self.text = "This game utilizes an autosave feature.\n"..
              "It will run each time you reach a new level or checkpoint.\n" ..
              "You can also manually save in the options if you're ever in a hurry."

end

function state:enter()
  local h = anim8.newGrid(17, 16, self.savingImage:getDimensions())
  self.savingAnimation = anim8.newAnimation('loop', h('1-7,1'), 0.1, {[7] = 0.4})
  Timer.add(8, function()
    Gamestate.switch('scanning')
  end)
end

function state:leave()
  self.current = nil
end

function state:draw()

  love.graphics.setColor( 255, 255, 255, 255 )
  VerticalParticles.draw()
  
  local width = self.background:getWidth()
  local height = self.background:getHeight()
  
  local x = (window.width - width)/2
  local y = (window.height - height)/2

  love.graphics.draw(self.background, x, y)
  self.savingAnimation:draw(self.savingImage, x + 10, y + 10)
  self.savingAnimation:draw(self.savingImage, x + width - 27, y + 10)
  self.savingAnimation:draw(self.savingImage, x + 10, y + height - 26)
  self.savingAnimation:draw(self.savingImage, x + width - 27, y + height - 26)

  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.printf(self.text, x + 10, y + 65, width - 20, "center")

end

function state:keypressed(button)
  Timer.clear()
  Gamestate.switch('scanning')
end

function state:update(dt)
  VerticalParticles.update(dt)
  self.savingAnimation:update(dt)
end

return state
