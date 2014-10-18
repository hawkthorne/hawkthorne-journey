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
  self.name = "welcome"
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
  self.code_short = {}
  self.code_count = {}
  self.count_check = {}
  for i = 1, 7 do
    self.code_short[i] = ""
    self.code_count[i] = 1
    self.count_check[i] = 23*(i-1)
  end
  self.code_timer = 0
  self.code_loaded = false

  self.previous = previous
end

function state:keypressed( button )
  self.code_loaded = true
  
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
        self.line_timer = self.line_timer + 4*dt
        self.code_timer = 0
        for i = 1, 7 do
          if self.code_count[1] > self.count_check[i] then
            self.code_short[i] = self.code_short[i]..self.code.sub(self.code, self.code_count[i], self.code_count[i])
            self.code_count[i] = self.code_count[i] + 1
          end
        end
      end
    end
   end
   if self.code_count[1] > 310 then
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
    for i = 1, 7 do
      love.graphics.print(self.code_short[i], 60*i - 10, 130, 0, 0.4, 0.4)
    end
  else
    love.graphics.print(self.line, 50, 50, 0, 0.5, 0.5 )
    for i = 1, 7 do
      love.graphics.print(self.code, 60*i - 10, 130, 0, 0.4, 0.4)
    end
  end

  love.graphics.setColor(255, 255, 255)
  fonts.set( 'big' )

  -- menu
  local x = window.width / 2 - self.splash:getWidth()/2
  local y = 2*window.height / 2.5 - self.splash:getHeight()/2
  if self.code_loaded then
    love.graphics.draw(self.splash, x, y)
    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))
    for n,option in ipairs(self.menu.options) do
      love.graphics.print(app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end
    self.menu_shown = true
    -- control instructions
    love.graphics.print(self.text, window.width/2-65, window.height - 24, 0, 0.5, 0.5)
  end

end

function state:leave()
  
  self.line = nil
  self.line_short = nil
  self.line_count = nil
  self.line_timer = nil

  self.code = nil
  self.code_timer = nil
  self.code_count = {}
  self.code_short = {}
  self.count_check = {}

  self.splash = nil
  self.arrow = nil
  self.text = nil
  self.code_loaded = false
  self.menu_shown = false
 
  fonts.reset()
end

return state
