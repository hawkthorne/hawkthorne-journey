local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local state = Gamestate.new()

function state:init()
    self:refresh()
	self.camera_x = {y=camera.x}
	self.camera_final = 1586
	self.runTime = 30
	tween(self.runTime, self.camera_x, {y=self.camera_final})
end

function state:enter(previous)
  self:refresh()
  self.music = sound.playMusic( "ending" )
  self.previous = previous
end

function state:keypressed( button )
  Timer.clear()
  Gamestate.switch("select")
end

function state:update(dt)
  self.walk2animate:update(dt)
  self.walk3animate:update(dt)
  self.walkTroyanimate:update(dt)
  
  camera.x = self.camera_x.y
end

function state:draw()

  --background colour
  love.graphics.setColor( 89, 156, 225, 255 )
  love.graphics.rectangle( 'fill', camera.x, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 255, 255, 255, 255 )
  
  -- banner
  love.graphics.draw(self.banner, 528, 139)
  
  -- animations
  self.walk2animate:draw(self.walk2, 528, 180)
  self.walk3animate:draw(self.walk3, 528, 180)
  self.walkTroyanimate:draw(self.walkTroy, 954, 119)
end

function state:refresh()
  -- sets length of time for animation
  local runTime = 100

  self.walk2 = love.graphics.newImage('images/surprise/walk2.png')
  self.walk3 = love.graphics.newImage('images/surprise/walk3.png')
  self.walkTroy = love.graphics.newImage('images/surprise/walkTroy.png')
  self.banner = love.graphics.newImage('images/surprise/banner.png')
  
  local g1 = anim8.newGrid(1056, 52, self.walk2:getWidth(), self.walk2:getHeight())
  local g2 = anim8.newGrid(840, 52, self.walk3:getWidth(), self.walk3:getHeight())
  local g3 = anim8.newGrid(49, 113, self.walkTroy:getWidth(), self.walkTroy:getHeight())

  state.walk2animate = anim8.newAnimation('loop', g1('1, 1-2'), 0.2)
  state.walk3animate = anim8.newAnimation('loop', g2('1, 1-3'), 0.16)
  state.walkTroyanimate = anim8.newAnimation('loop', g3('1-3, 1'), 0.2)
  
-- animation runs for runTime secs
  Timer.add(self.runTime, function() Gamestate.switch("splash") end)
end


function state:leave() 
  self.music = nil
  self.camera_x = nil
  self.camera_final = nil
  self.runtime = nil
  
  self.walk2 = nil
  self.walk3 = nil
  self.walkTroy = nil

  state.walk2animate = nil
  state.walk3animate = nil
  state.walkTroyanimate = nil
end

return state
