local Gamestate = require 'vendor/gamestate'
local fonts = require 'fonts'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local state = Gamestate.new()


function state:init()
    self:refresh()
end


function state:enter(previous)
  self:refresh()
  self.previous = previous
  self.music = sound.playMusic("opening")
end

function state:keypressed( button )
  Timer.clear()
  if button == "START" then
    Gamestate.switch("start")
    return true
  else
    Gamestate.switch("select")
  end
end

function state:update(dt)
  self.backgroundanimate:update(dt)
  self.namesanimate:update(dt)
  self.computeranimate:update(dt)
  self.descriptionanimate:update(dt)
  self.scanbaranimate:update(dt)
  self.scanwordsanimate:update(dt)

  self.blankanimate:update(dt)
  self.ispritesanimate:update(dt)
  self.iscananimate:update(dt)

  self.jeffanimation:update(dt)
  self.brittaanimation:update(dt)
  self.abedanimation:update(dt)
  self.shirleyanimation:update(dt)
  self.annieanimation:update(dt)
  self.troyanimation:update(dt)
  self.pierceanimation:update(dt)
end

function state:draw()

  --background colour
  love.graphics.setColor( 60, 86, 173, 255 )
  love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
  love.graphics.setColor( 255, 255, 255, 255 )

  -- coloured backgrounds
  local width = window.width
  local height = window.height
  local xcorner = width/2 - 200
  local ycorner = height/2 - 125
  
  -- animations

  self.backgroundanimate:draw(self.backgrounds, xcorner, ycorner)
  self.namesanimate:draw(self.names, xcorner + 162, ycorner + 35)
  self.computeranimate:draw(self.computer, xcorner + 162, ycorner + 150)
  self.descriptionanimate:draw(self.description, xcorner + 39, ycorner + 210)
  self.scanbaranimate:draw(self.scanbar, xcorner + 240, ycorner + 210)
  self.scanwordsanimate:draw(self.scanwords, xcorner + 240, ycorner + 225)

  self.blankanimate:draw(self.blank, xcorner + 240, ycorner + 30)
  self.ispritesanimate:draw(self.isprites, xcorner + 240, ycorner + 30)
  self.iscananimate:draw(self.iscan, xcorner + 39, ycorner + 30)

  self.jeffanimation:draw(self.jeff, xcorner + 39, ycorner + 30)
  self.brittaanimation:draw(self.britta, xcorner + 39, ycorner + 30)
  self.abedanimation:draw(self.abed, xcorner + 39, ycorner + 30)
  self.shirleyanimation:draw(self.shirley, xcorner + 39, ycorner + 30)
  self.annieanimation:draw(self.annie, xcorner + 39, ycorner + 30)
  self.troyanimation:draw(self.troy, xcorner + 39, ycorner + 30)
  self.pierceanimation:draw(self.pierce, xcorner + 39, ycorner + 30)

end

function state:refresh()
  -- sets length of time for animation
  local rtime = 10

  -- calculates time for each character, with and without flashing animation at end
  local ctime = rtime/7
  local ftime = ctime/3
  local stime = ctime - ftime

  self.backgrounds = love.graphics.newImage('images/scanning/backgrounds.png')
  self.names = love.graphics.newImage('images/scanning/names.png')
  self.computer = love.graphics.newImage('images/scanning/computer.png')
  self.description = love.graphics.newImage('images/scanning/description.png')
  self.scanbar = love.graphics.newImage('images/scanning/scanningbar.png')
  self.scanwords = love.graphics.newImage('images/scanning/scanningwords.png')

  self.blank = love.graphics.newImage('images/scanning/blankscan.png')
  self.isprites = love.graphics.newImage('images/scanning/invertedsprites.png')
  self.iscan = love.graphics.newImage('images/scanning/invertedscan.png')

  self.jeff = love.graphics.newImage('images/scanning/jeffscan.png')
  self.britta = love.graphics.newImage('images/scanning/brittascan.png')
  self.abed = love.graphics.newImage('images/scanning/abedscan.png')
  self.shirley = love.graphics.newImage('images/scanning/shirleyscan.png')
  self.annie = love.graphics.newImage('images/scanning/anniescan.png')
  self.troy = love.graphics.newImage('images/scanning/troyscan.png')
  self.pierce = love.graphics.newImage('images/scanning/piercescan.png')

  local g1 = anim8.newGrid(400, 250, self.backgrounds:getWidth(), self.backgrounds:getHeight())
  local g2 = anim8.newGrid(75, 15, self.names:getWidth(), self.names:getHeight())
  local g3 = anim8.newGrid(75, 19, self.computer:getWidth(), self.computer:getHeight())
  local g4 = anim8.newGrid(121, 13, self.description:getWidth(), self.description:getHeight())
  local g5 = anim8.newGrid(121, 13, self.scanbar:getWidth(), self.scanbar:getHeight())
  local g6 = anim8.newGrid(121, 13, self.scanwords:getWidth(), self.scanwords:getHeight())

  local g7 = anim8.newGrid(121, 172, self.blank:getWidth(), self.blank:getHeight())
  local g8 = anim8.newGrid(121, 172, self.isprites:getWidth(), self.isprites:getHeight())
  local g9 = anim8.newGrid(121, 172, self.iscan:getWidth(), self.iscan:getHeight())

  local g10 = anim8.newGrid(121, 172, self.jeff:getWidth(), self.jeff:getHeight())
  local g11 = anim8.newGrid(121, 172, self.britta:getWidth(), self.britta:getHeight())
  local g12 = anim8.newGrid(121, 172, self.abed:getWidth(), self.abed:getHeight())
  local g13 = anim8.newGrid(121, 172, self.shirley:getWidth(), self.shirley:getHeight())
  local g14 = anim8.newGrid(121, 172, self.annie:getWidth(), self.annie:getHeight())
  local g15 = anim8.newGrid(121, 172, self.troy:getWidth(), self.troy:getHeight())
  local g16 = anim8.newGrid(121, 172, self.pierce:getWidth(), self.pierce:getHeight())

  state.backgroundanimate = anim8.newAnimation('once', g1('1-2, 1', '1-2, 2', '1-2, 3', '1, 4'), ctime) 
  state.namesanimate = anim8.newAnimation('once', g2('1, 1-6', '1, 1-5', '1, 7', '1, 1-5', '1, 8', '1, 1-5', '1, 9', '1, 1-5', '1, 10', '1, 1-5', '1, 11', '1, 1-5', '1, 12' ), 
                                        ftime/6, {[1]=stime, [6]=ftime/3, [7]=stime, [12]=ftime/3, [13]=stime, 
                                        [18] = ftime/3, [19]=stime, [24]=ftime/3, [25]=stime, [30]=ftime/3, 
                                        [31]=stime, [36]=ftime/3, [37]=stime})
  state.computeranimate = anim8.newAnimation('loop', g3('1, 1-9'), 0.08)
  state.descriptionanimate = anim8.newAnimation('loop', g4('1, 1-12', '1, 12'), stime/12, {[13]=ftime})
  state.scanbaranimate = anim8.newAnimation('loop', g5('1, 1-16', '1, 17'), (ctime-ftime*2/5)/16, {[17]=ftime*2/5})
  state.scanwordsanimate = anim8.newAnimation('loop', g6('1, 1-4', '1, 1-4', '1, 5'), (ctime-ftime*2/5)/8, {[9]=ftime*2/5})

  state.blankanimate = anim8.newAnimation('loop', g7('1-6, 1', '1-6, 2'), stime/11, {[12]=ftime}) 
  state.ispritesanimate = anim8.newAnimation('once', g8('2, 8', '2, 1', '1, 8', '1, 1', '4, 1', '3, 1', '3, 1',
                                        '2, 8', '2, 2', '1, 8', '1, 2', '4, 2', '3, 2', '3, 2',
                                        '2, 8', '2, 3', '1, 8', '1, 3', '4, 3', '3, 3', '3, 3',
                                        '2, 8', '2, 4', '1, 8', '1, 4', '4, 4', '3, 4', '3, 4',
                                        '2, 8', '2, 5', '1, 8', '1, 5', '4, 5', '3, 5', '3, 5',
                                        '2, 8', '2, 6', '1, 8', '1, 6', '4, 6', '3, 6', '3, 6',
                                        '2, 8', '2, 7', '1, 8', '1, 7', '4, 7', '3, 7', '3, 7'), 
                                        ftime/6, {[1]=stime, [8]=stime, [15]=stime, [22]=stime, [29]=stime, [36]=stime, [43]=stime}) 
  state.iscananimate = anim8.newAnimation('once', g9('1, 2', '4, 1', '1, 1', '3, 1', '4, 1', '3, 1', '3, 1',
                                        '2, 1', '2, 2', '1, 1', '1, 2', '2, 2', '1, 2', '1, 2',
                                        '2, 1', '4, 2', '1, 1', '3, 2', '4, 2', '3, 2', '3, 2',
                                        '2, 1', '2, 3', '1, 1', '1, 3', '2, 3', '1, 3', '1, 3',
                                        '2, 1', '4, 3', '1, 1', '3, 3', '4, 3', '3, 3', '3, 3',
                                        '2, 1', '2, 4', '1, 1', '1, 4', '2, 4', '1, 4', '1, 4',
                                        '2, 1', '4, 4', '1, 1', '3, 4', '4, 4', '3, 4', '3, 4'), 
                                        ftime/6, {[1]=stime, [8]=stime, [15]=stime, [22]=stime, [29]=stime, [36]=stime, [43]=stime})
  
  state.jeffanimation = anim8.newAnimation('once', g10('2-8, 1', '1-8, 2', '1-4, 3', '7, 3'), stime/19)
  state.brittaanimation = anim8.newAnimation('once', g11('7, 3', '1-7, 1', '1-7, 2', '1-4, 3', '7, 3'), stime/18, {[1]=ctime})
  state.abedanimation = anim8.newAnimation('once', g12('7, 3', '1-7, 1', '1-7, 2', '1-3, 3', '7, 3'), stime/17, {[1]=2*ctime})
  state.shirleyanimation = anim8.newAnimation('once', g13('4, 3', '1-6, 1', '1-6, 2', '4, 3'), stime/12, {[1]=3*ctime})
  state.annieanimation = anim8.newAnimation('once', g14('5, 4', '1-5, 1' , '1-5, 2' , '1-5, 3', '1-2, 4', '5, 4'), stime/16, {[1]=4*ctime})
  state.troyanimation = anim8.newAnimation('once', g15('5, 3', '1-7, 1', '1-7, 2', '1-2, 3', '5, 3'), stime/15, {[1]=5*ctime})
  state.pierceanimation = anim8.newAnimation('once', g16('4, 3', '2-5, 1', '1-5, 2', '1-3, 3', '4, 3'), stime/12, {[1]=6*ctime})

-- animation runs for rtime secs
  Timer.add(rtime, function() Gamestate.switch("select") end)
end


function state:leave() 
  self.backgrounds = nil
  self.names = nil
  self.computer = nil
  self.description = nil
  self.scanbar = nil
  self.scanwords = nil 
  self.blank = nil
  self.isprites = nil
  self.iscan = nil
  self.jeff = nil
  self.britta = nil
  self.abed = nil
  self.shirley = nil
  self.annie = nil
  self.troy = nil
  self.pierce = nil

  state.backgroundanimate = nil
  state.namesanimate = nil
  state.computeranimate = nil
  state.descriptionanimate = nil
  state.scanbaranimate = nil
  state.scanwordsanimate = nil
  state.blankanimate = nil
  state.ispritesanimate = nil
  state.iscananimate = nil
  state.jeffanimation = nil
  state.brittaanimation = nil
  state.abedanimation = nil
  state.shirleyanimation = nil
  state.annieanimation = nil
  state.troyanimation = nil
  state.pierceanimation = nil
end

return state
