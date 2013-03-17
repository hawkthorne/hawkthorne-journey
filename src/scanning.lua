local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local fonts = require 'fonts'
local state = Gamestate.new()
local part = require 'verticalparticles'
local character = require 'character'

local annieanimation1, annieanimation2, annieanimation3, annieanimation4, annieanimation5, annieanimation6, annieanimation7, annieanimation8 

function state:init()
  self.image1 = love.graphics.newImage('images/scanning/anniebackground.png')
  self.image2 = love.graphics.newImage('images/scanning/anniescan.png')
  self.image3 = love.graphics.newImage('images/scanning/anniesprite.png')
  self.image4 = love.graphics.newImage('images/scanning/anniename.png')
  self.image5 = love.graphics.newImage('images/scanning/computer.png')
  self.image6 = love.graphics.newImage('images/scanning/description.png')
  self.image7 = love.graphics.newImage('images/scanning/scanningbar.png')
  self.image8 = love.graphics.newImage('images/scanning/scanningwords.png')

  local g = anim8.newGrid(400, 250, self.image1:getWidth(), self.image1:getHeight())
  local h = anim8.newGrid(121, 172, self.image2:getWidth(), self.image2:getHeight())
  local i = anim8.newGrid(121, 172, self.image3:getWidth(), self.image3:getHeight())
  local j = anim8.newGrid(75, 15, self.image4:getWidth(), self.image4:getHeight())
  local k = anim8.newGrid(75, 19, self.image5:getWidth(), self.image5:getHeight())
  local l = anim8.newGrid(121, 13, self.image6:getWidth(), self.image6:getHeight())
  local m = anim8.newGrid(121, 13, self.image7:getWidth(), self.image7:getHeight())
  local n = anim8.newGrid(121, 13, self.image8:getWidth(), self.image8:getHeight())

  annieanimation1 = anim8.newAnimation('once', g('1, 1'), 0.2)
  annieanimation2 = anim8.newAnimation('loop', h('1-5, 1' , '1-5, 2' , '1-5, 3', '1-4, 4'), 0.05)
  annieanimation3 = anim8.newAnimation('loop', i('1-5, 1','1-5, 2','1, 3'), 0.1)
  annieanimation4 = anim8.newAnimation('loop', j('1, 1-6'), 0.2)
  annieanimation5 = anim8.newAnimation('loop', k('1, 1-9'), 0.05)
  annieanimation6 = anim8.newAnimation('loop', l('1, 1-8'), 0.1)
  annieanimation7 = anim8.newAnimation('loop', m('1, 1-5'), 0.4)
  annieanimation8 = anim8.newAnimation('loop', n('1, 1-4','1,1-4','1,5'), 0.2)

end

function state:keypressed( button )
    Timer.clear()
    Gamestate.switch("select")
end

-- animation runs for 2 secs
Timer.add(2, function() Gamestate.switch('select') end)


function state:update(dt)
  annieanimation1:update(dt)
  annieanimation2:update(dt)
  annieanimation3:update(dt)
  annieanimation4:update(dt)
  annieanimation5:update(dt)
  annieanimation6:update(dt)
  annieanimation7:update(dt)
  annieanimation8:update(dt)
end


function state:draw()

  --background colour
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 255, 255, 255, 255 )

  --table
  local width = window.width
  local height = window.height
  local xcorner = width/2 - self.image1:getWidth()/2
  local ycorner = height/2 - self.image1:getHeight()/2
  
  -- animations
  annieanimation1:draw(self.image1, xcorner, ycorner)
  annieanimation2:draw(self.image2, xcorner + 39, ycorner + 30)
  annieanimation3:draw(self.image3, xcorner + 240, ycorner + 30)
  annieanimation4:draw(self.image4, xcorner + 162, ycorner + 35)
  annieanimation5:draw(self.image5, xcorner + 162, ycorner + 150)
  annieanimation6:draw(self.image6, xcorner + 39, ycorner + 210)
  annieanimation7:draw(self.image7, xcorner + 240, ycorner + 210)
  annieanimation8:draw(self.image8, xcorner + 240, ycorner + 225)

end

return state