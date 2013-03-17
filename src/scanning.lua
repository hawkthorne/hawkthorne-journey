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

-- sets length of time for scanning animation & for each character
local rtime = 10
local ctime = rtime/7


function state:init()

  self.backgrounds = love.graphics.newImage('images/scanning/backgrounds.png')
  self.names = love.graphics.newImage('images/scanning/names.png')
  self.sprites = love.graphics.newImage('images/scanning/sprites.png')

  self.computer = love.graphics.newImage('images/scanning/computer.png')
  self.description = love.graphics.newImage('images/scanning/description.png')
  self.scanbar = love.graphics.newImage('images/scanning/scanningbar.png')
  self.scanwords = love.graphics.newImage('images/scanning/scanningwords.png')

  self.britta = love.graphics.newImage('images/scanning/brittascan.png')
  self.annie = love.graphics.newImage('images/scanning/anniescan.png')


  local g1 = anim8.newGrid(400, 250, self.backgrounds:getWidth(), self.backgrounds:getHeight())
  local g2 = anim8.newGrid(75, 15, self.names:getWidth(), self.names:getHeight())
  local g3 = anim8.newGrid(121, 172, self.sprites:getWidth(), self.sprites:getHeight())

  local g4 = anim8.newGrid(75, 19, self.computer:getWidth(), self.computer:getHeight())
  local g5 = anim8.newGrid(121, 13, self.description:getWidth(), self.description:getHeight())
  local g6 = anim8.newGrid(121, 13, self.scanbar:getWidth(), self.scanbar:getHeight())
  local g7 = anim8.newGrid(121, 13, self.scanwords:getWidth(), self.scanwords:getHeight())

  local g9 = anim8.newGrid(121, 172, self.britta:getWidth(), self.britta:getHeight())
  local g12 = anim8.newGrid(121, 172, self.annie:getWidth(), self.annie:getHeight())


  backgroundanimate = anim8.newAnimation('once', g1('1-2, 1', '1-2, 2', '1-2, 3', '1, 4'), ctime) 
  namesanimate = anim8.newAnimation('once', g2('1, 1-6', '1, 1-5', '1, 7', '1, 1-5', '1, 8', '1, 1-5', '1, 9', '1, 1-5', '1, 10', '1, 1-5', '1, 11', '1, 1-5', '1, 12' ), ctime/6)
  spritesanimate = anim8.newAnimation('once', g3('1-4, 1', '1-3, 2', '1-4, 3', '1-4, 1', '1-3, 2', '1-4, 4', '1-4, 1', '1-3, 2', '1-4, 5', '1-4, 1', '1-3, 2', '1-4, 6', '1-4, 1', '1-3, 2', '1-4, 7', '1-4, 1', '1-3, 2', '1-4, 8', '1-4, 1', '1-3, 2', '1-4, 9'), ctime/11)

  computeranimate = anim8.newAnimation('loop', g4('1, 1-9'), 0.08)
  descriptionanimate = anim8.newAnimation('loop', g5('1, 1-8'), ctime/8)
  scanbaranimate = anim8.newAnimation('loop', g6('1, 1-5'), ctime/5)
  scanwordsanimate = anim8.newAnimation('loop', g7('1, 1-4', '1, 1-4', '1, 5'), ctime/9)

  brittaanimation = anim8.newAnimation('once', g9('7, 3', '1-7, 1', '1-7, 2', '1-7, 3'), ctime/20, {[1]=ctime})
  annieanimation = anim8.newAnimation('once', g12('5, 4', '1-5, 1' , '1-5, 2' , '1-5, 3', '1-4, 4', '5, 4'), ctime/19, {[1]=ctime*4})


end

function state:keypressed( button )
    Timer.clear()
    Gamestate.switch("select")
end

-- animation runs for rtime secs
Timer.add(rtime, function() Gamestate.switch('select') end)


function state:update(dt)

  backgroundanimate:update(dt)
  namesanimate:update(dt)
  spritesanimate:update(dt)

  computeranimate:update(dt)
  descriptionanimate:update(dt)
  scanbaranimate:update(dt)
  scanwordsanimate:update(dt)

  brittaanimation:update(dt)
  annieanimation:update(dt)

end


function state:draw()

  --background colour
  --background colour needs to be changed to blue
  love.graphics.setColor( 0, 0, 0, 255 )
  love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 255, 255, 255, 255 )

  --table
  local width = window.width
  local height = window.height
  local xcorner = width/2 - 200
  local ycorner = height/2 - 125
  
  -- animations

  backgroundanimate:draw(self.backgrounds, xcorner, ycorner)
  namesanimate:draw(self.names, xcorner + 162, ycorner + 35)
  spritesanimate:draw(self.sprites, xcorner + 240, ycorner + 30)

  computeranimate:draw(self.computer, xcorner + 162, ycorner + 150)
  descriptionanimate:draw(self.description, xcorner + 39, ycorner + 210)
  scanbaranimate:draw(self.scanbar, xcorner + 240, ycorner + 210)
  scanwordsanimate:draw(self.scanwords, xcorner + 240, ycorner + 225)

  brittaanimation:draw(self.britta, xcorner + 39, ycorner + 30)
  annieanimation:draw(self.annie, xcorner + 39, ycorner + 30)


end

return state