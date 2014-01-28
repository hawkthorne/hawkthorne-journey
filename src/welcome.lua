local anim8 = require 'vendor/anim8'
local app = require 'app'
local controls  = require('inputcontroller').get()
local fonts     = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local menu      = require 'menu'
local sound = require 'vendor/TEsound'
local window    = require 'window'

local state = Gamestate.new()

function state:init()

  self.menu = menu.new({ 'start', 'controls', 'options', 'credits', 'exit' })
  self.menu:onSelect(function(option)
    if option == 'exit' then
      love.event.push("quit")
    elseif option == 'controls' then
      Gamestate.switch('instructions')
    else
      Gamestate.switch(option)
    end
  end)

end

function state:enter(previous)
  self.splash = love.graphics.newImage("images/openingmenu.png")
  self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
  self.text = string.format(app.i18n('s_or_s_select_item'), controls:getKey('JUMP'), controls:getKey('ATTACK') )
  self.bg = sound.playMusic("ending")

  self.line = " terminal:// \n\n operations://loadprogram:(true) \n\n"..
    " program:-journey-to-the-center-of-hawkthorne \n\n loading simulation ..."
  self.line_short = ""
  self.line_count = 1
  self.line_timer = 0

  self.previous = previous
end

function state:keypressed( button )
  self.menu:keypressed(button)
end

function state:update(dt)
  
   self.line_timer = self.line_timer + dt
   if self.line_timer > 0.05 then
    self.line_timer = 0
    self.line_short = self.line_short..self.line.sub(self.line, self.line_count, self.line_count)
    self.line_count = self.line_count + 1
  end
end

function state:draw()

  --background colour
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 255, 255, 255, 255 )

-- green terminal
  fonts.set('courier')
  love.graphics.setColor( 48, 254, 31, 225 )
  love.graphics.print(self.line_short, 50, 50, 0, 0.5, 0.5 )

  -- control instructions
  love.graphics.setColor(255, 255, 255)	
  fonts.set( 'big' )
  love.graphics.printf(self.text, 0, window.height - 32, window.width, 'center', 0.5, 0.5)
 
  -- menu
  local x = window.width / 2 - self.splash:getWidth()/2
  local y = 2*window.height / 3 - self.splash:getHeight()/2
  love.graphics.draw(self.splash, x, y)
  love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))
  for n,option in ipairs(self.menu.options) do
    love.graphics.print(app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
  end
end

function state:leave()
  
  self.line = nil
  self.line_short = nil
  self.line_count = nil
  self.line_timer = nil

  self.splash = nil
  self.arrow = nil
  self.text = nil
 
  fonts.reset()
end

return state
