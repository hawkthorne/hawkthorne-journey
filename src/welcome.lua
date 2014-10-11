local anim8 = require 'vendor/anim8'
local app = require 'app'
local controls  = require('inputcontroller').get()
local fonts     = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local menu      = require 'menu'
local sound = require 'vendor/TEsound'
local window    = require 'window'
local Timer = require 'vendor/timer'

local state = Gamestate.new()

function state:init()
--
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
  self.code = " 5465415151 \n\n 5465415151 \n\n".. " 5465415151 \n\n 1651094097 \n\n 9046515154 \n\n 5490490456 \n\n 1571754564 \n\n 8940186515 \n\n 6454040940 \n\n 1651321894 \n\n 8979046541 \n\n 1216547789 \n\n 4651561165 \n\n 1121894897 \n\n 2278578589 \n\n 2857868678 \n\n 8678668287 \n\n 2784785786 \n\n 7868767867 \n\n 8678678678 \n\n 6786786786 \n\n 7867867867 \n\n 9447944794 \n\n 4794479447"
  self.code_short = ""
  self.code_short2 = ""
  self.code_short3 = ""
  self.code_short4 = ""
  self.code_short5 = ""
  self.code_short6 = ""
  self.code_short7 = ""
  self.code_count = 1
  self.code_count2 = 1
  self.code_count3 = 1
  self.code_count4 = 1
  self.code_count5 = 1
  self.code_count6 = 1
  self.code_count7 = 1
  self.code_timer = 0
  self.code_loaded = false

  self.previous = previous
end

function state:keypressed( button )
  if button == 'JUMP' or button == 'ATTACK' then
    self.code_loaded = true
    --self.menu:keypressed(button)
  end
  if self.menu_shown then
    self.menu:keypressed(button)
  end
end

function state:update(dt)
  
   self.line_timer = self.line_timer + dt
   self.code_timer = self.code_timer + dt
   if self.line_timer > 0.05 then
    self.line_timer = 0
    self.line_short = self.line_short..self.line.sub(self.line, self.line_count, self.line_count)
    self.line_count = self.line_count + 1
    if self.line_count >135 then
      if self.code_timer > 0.005 then
        self.code_timer = 0
        self.code_short = self.code_short..self.code.sub(self.code, self.code_count, self.code_count)
        self.code_count = self.code_count + 1
        if self.code_count >23 then
          self.code_short2 = self.code_short2..self.code.sub(self.code, self.code_count2, self.code_count2)
          self.code_count2 = self.code_count2 + 1
        end
        if self.code_count >46 then
          self.code_short3 = self.code_short3..self.code.sub(self.code, self.code_count3, self.code_count3)
          self.code_count3 = self.code_count3 + 1
        end
        if self.code_count >69 then
          self.code_short4 = self.code_short4..self.code.sub(self.code, self.code_count4, self.code_count4)
          self.code_count4 = self.code_count4 + 1
        end
        if self.code_count >92 then
          self.code_short5 = self.code_short5..self.code.sub(self.code, self.code_count5, self.code_count5)
          self.code_count5 = self.code_count5 + 1
        end
        if self.code_count >125 then
          self.code_short6 = self.code_short6..self.code.sub(self.code, self.code_count6, self.code_count6)
          self.code_count6 = self.code_count6 + 1
        end
        if self.code_count >148 then
          self.code_short7 = self.code_short7..self.code.sub(self.code, self.code_count7, self.code_count7)
          self.code_count7 = self.code_count7 + 1
        end
      end
    end
   end
   if self.code_count > 310 then
    self.code_loaded = true
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
  if self.code_loaded == false then
    love.graphics.print(self.line_short, 50, 50, 0, 0.5, 0.5 )
    love.graphics.print(self.code_short, 50, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short2, 110, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short3, 170, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short4, 230, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short5, 290, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short6, 350, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code_short7, 410, 130, 0, 0.4, 0.4 )
  else 
    love.graphics.print(self.line, 50, 50, 0, 0.5, 0.5 )
    love.graphics.print(self.code, 50, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 110, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 170, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 230, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 290, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 350, 130, 0, 0.4, 0.4 )
    love.graphics.print(self.code, 410, 130, 0, 0.4, 0.4 )
  end

  love.graphics.setColor(255, 255, 255)
  fonts.set( 'big' )

  -- menu
  local x = window.width / 2 - self.splash:getWidth()/2
  local y = 2*window.height / 3 - self.splash:getHeight()/2
  if self.code_loaded then
    love.graphics.draw(self.splash, x, y)
    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))
    for n,option in ipairs(self.menu.options) do
      love.graphics.print(app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end
    self.menu_shown = true
  end


	
  -- control instructions
  love.graphics.print(self.text, x - 25, window.height - 52, 0, 0.5, 0.5)

end

function state:leave()
  
  self.line = nil
  self.line_short = nil
  self.line_count = nil
  self.line_timer = nil

  self.code = nil
  self.code_short = nil
  self.code_count = nil
  self.code_timer = nil
  self.code_short2 = nil
  self.code_count2 = nil
  self.code_short3 = nil
  self.code_count3 = nil
  self.code_short4 = nil
  self.code_count4 = nil
  self.code_short5 = nil
  self.code_count5 = nil
  self.code_short6 = nil
  self.code_count6 = nil
  self.code_short7 = nil
  self.code_count7 = nil

  self.splash = nil
  self.arrow = nil
  self.text = nil
 
  fonts.reset()
end

return state
