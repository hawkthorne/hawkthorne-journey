local anim8 = require 'vendor/anim8'
local app = require 'app'
local camera = require 'camera'
local controls  = require('inputcontroller').get()
local fonts     = require 'fonts'
local Gamestate = require 'vendor/gamestate'
local menu      = require 'menu'
local sound = require 'vendor/TEsound'
local tween = require 'vendor/tween'
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

  self:refresh()
  self.camera_x = {y=camera.x}
  self.camera_final = 1586
  self.runTime = 20
  tween(self.runTime, self.camera_x, {y=self.camera_final})
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

  self:refresh()
  self.previous = previous
end

function state:keypressed( button )
  if self.camera_x.y >= self.camera_final then
    self.menu:keypressed(button)
  end
end

function state:update(dt)
  self.walk2animate:update(dt)
  self.walk3animate:update(dt)
  self.walkTroyanimate:update(dt)

  camera.x = self.camera_x.y
  
   self.line_timer = self.line_timer + dt
   if self.line_timer > 0.05 and camera.x >= self.camera_final then
    self.line_timer = 0
    self.line_short = self.line_short..self.line.sub(self.line, self.line_count, self.line_count)
    self.line_count = self.line_count + 1
  end
end

function state:draw()

  --background colour
  love.graphics.setColor( 89, 156, 225, 255 )
  love.graphics.rectangle( 'fill', camera.x, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle( 'fill', self.camera_final, 0, love.graphics:getWidth(), love.graphics:getHeight())
  love.graphics.setColor( 255, 255, 255, 255 )
  
  -- animations & banner
  self.walk2animate:draw(self.walk2, 528, 180)
  self.walk3animate:draw(self.walk3, 528, 180)
  love.graphics.draw(self.banner, 529, 137)
  self.walkTroyanimate:draw(self.walkTroy, 916, 119)


  if self.camera_x.y >= self.camera_final then
    -- green terminal
    fonts.set('courier')
    love.graphics.setColor( 48, 254, 31, 225 )
    love.graphics.print(self.line_short, 50 + camera.x, 50, 0, 0.5, 0.5 )

    -- control instructions
    love.graphics.setColor(255, 255, 255)	
    fonts.set( 'big' )
    love.graphics.printf(self.text, camera.x, window.height - 32, window.width, 'center', 0.5, 0.5)
	
    -- menu
    local x = window.width / 2 - self.splash:getWidth()/2 + camera.x
    local y = 2*window.height / 3 - self.splash:getHeight()/2
    love.graphics.draw(self.splash, x, y)
    love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))
    for n,option in ipairs(self.menu.options) do
      love.graphics.print(app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
    end
  end
end

function state:refresh()
  local runTime = 30
  
  self.walk2 = love.graphics.newImage('images/menu/walk2.png')
  self.walk3 = love.graphics.newImage('images/menu/walk3.png')
  self.walkTroy = love.graphics.newImage('images/menu/walkTroy.png')
  self.banner = love.graphics.newImage('images/menu/banner.png')
  
  local g1 = anim8.newGrid(1056, 52, self.walk2:getWidth(), self.walk2:getHeight())
  local g2 = anim8.newGrid(1056, 52, self.walk3:getWidth(), self.walk3:getHeight())
  local g3 = anim8.newGrid(49, 113, self.walkTroy:getWidth(), self.walkTroy:getHeight())

  state.walk2animate = anim8.newAnimation('loop', g1('1, 1-2'), 0.2)
  state.walk3animate = anim8.newAnimation('loop', g2('1, 1-3'), 0.16)
  state.walkTroyanimate = anim8.newAnimation('loop', g3('1-3, 1'), 0.2)
end


function state:leave() 
  camera.x = 0
  
  self.line = nil
  self.line_short = nil
  self.line_count = nil
  self.line_timer = nil
  
  self.walk2 = nil
  self.walk3 = nil
  self.walkTroy = nil
  self.banner = nil
  
  self.splash = nil
  self.arrow = nil
  self.text = nil

  state.walk2animate = nil
  state.walk3animate = nil
  state.walkTroyanimate = nil
  
  fonts.reset()
end

return state
