local app = require 'app'
local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local window    = require 'window'
local fonts     = require 'fonts'
local splash    = Gamestate.new()
local camera    = require 'camera'
local tween     = require 'vendor/tween'
local sound     = require 'vendor/TEsound'
local controls  = require('inputcontroller').get()
local timer     = require 'vendor/timer'
local VerticalParticles = require "verticalparticles"


function splash:init()
  self.name = 'splash'
  VerticalParticles.init()

  camera.x = 528
  self.camera_x = {y = camera.x}
  self.camera_y = {y = camera.y}
  
  self.cityscape = love.graphics.newImage("images/menu/cityscape.png")
  self.logo = love.graphics.newImage("images/menu/logo.png")
  
  self.beams = love.graphics.newImage("images/menu/beams.png")
  local g1 = anim8.newGrid(99, 99, self.beams:getWidth(), self.beams:getHeight())
  self.beamsanimate = anim8.newAnimation('once', g1('1-5,1','1-5,2'), 0.03, {[1]=2,[5]=2})

  self.logo_position = {y=-self.logo:getHeight()}
  self.logo_position_final = self.logo:getHeight() / 2 + 40

  -- panning of camera & logo appears
  tween(2, self.camera_y, {y = window.height*2})
  timer.add(2, function() 
    tween(2, self.camera_x, {y = 0}) 
      timer.add(2, function() tween(4, self.logo_position, { y=self.logo_position_final}) end)
  end)

  -- sparkles
  self.sparklesprite = love.graphics.newImage('images/cutscenes/cornelius_sparkles.png')
  self.bling = anim8.newGrid(24, 24, self.sparklesprite:getWidth(), self.sparklesprite:getHeight())
  self.sparkles = {{55,34},{42,112},{132,139},{271,115},{274,50}}
  for _,_sp in pairs(self.sparkles) do
    _sp[3] = anim8.newAnimation('loop', self.bling('1-4,1'), 0.22 + math.random() / 10) 
    _sp[3]:gotoFrame( math.random( 4 ) ) 
  end

  -- press START flashing
  self.blink = 0

  -- 'double_speed' is used to speed up the animation of the logo + splash
  self.double_speed = false
end

function splash:enter(previous)
  fonts.set( 'big' )
  
  self.previous = previous
end

function splash:update(dt)

  camera.x = self.camera_x.y
  camera.y = self.camera_y.y

  if self.double_speed then
    tween.update(dt * 20)
  end

  for _,_sp in pairs(self.sparkles) do
    _sp[3]:update(dt)
  end

  self.blink = self.blink + dt < 1 and self.blink + dt or 0
  
  VerticalParticles.update(dt)
  self.beamsanimate:update(dt)
end

function splash:leave()

  local g1 = anim8.newGrid(99, 99, self.beams:getWidth(), self.beams:getHeight())
  self.beamsanimate = anim8.newAnimation('once', g1('5,2'), 0.1)
  
  fonts.reset()

  if self.handle then 
    timer.cancel(self.handle)
  end
end

function splash:keypressed( button )
  if self.logo_position.y < self.logo_position_final and camera.x == 0 then
    self.double_speed = true
  elseif self.logo_position.y == self.logo_position_final then
    Gamestate.switch('studyroom', 'main') 
  end
end

function splash:draw()

  VerticalParticles.draw()

  local xlogo = window.width / 2 - self.logo:getWidth()/2
  local ylogo = window.height / 2 - self.logo_position.y
   
  love.graphics.draw(self.cityscape)
  love.graphics.draw(self.logo, xlogo, ylogo + camera.y )

  self.beamsanimate:draw(self.beams, window.width*0.291 + camera.x, window.height*0.089 + camera.y)

  if camera.x == 0 then
    for _,_sp in pairs(self.sparkles) do
      _sp[3]:draw( self.sparklesprite, _sp[1] - 12 + xlogo, _sp[2] - 12 + ylogo + camera.y)
    end
  end

  if self.logo_position.y >= self.logo_position_final and self.blink <= 0.5 then
    love.graphics.printf("PRESS START", 0, window.height - 45 + camera.y, window.width, 'center', 0.5, 0.5)
  end
  
end

return splash
