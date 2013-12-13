local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'

local autosave_warning = Gamestate.new()

local savingImage = love.graphics.newImage('images/hud/saving.png')
savingImage:setFilter('nearest', 'nearest')

function autosave_warning:init( )
end

function autosave_warning:enter( prev )

  local h = anim8.newGrid(36, 36, savingImage:getWidth(), savingImage:getHeight())
  self.savingAnimation = anim8.newAnimation('loop', h('1-8,1'), .25)
  Timer.add(2, function()
    self:startGame()
  end)
end

function autosave_warning:leave()
  self.current = nil
end

function autosave_warning:draw()
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor( 255, 255, 255, 255 )
  local top = (window.height - 36)/2 
  local side = (window.width - 36)/2
  self.savingAnimation:draw(savingImage, side, top)
  love.graphics.setColor( 0, 0, 0, 255 )
  local warn1 = 'This game utilizes an autosave feature.'
  local offset1 = (window.width - love.graphics.getFont():getWidth(warn1))/2
  love.graphics.print(warn1, offset1, top + 36)
  local warn2 = 'Do not exit when this symbol is displayed.'
  local offset2 = (window.width - love.graphics.getFont():getWidth(warn2))/2
  love.graphics.print(warn2, offset2, top + 54)

end

function autosave_warning:startGame(dt)
  local gamesave = app.gamesaves:active()
  local point = gamesave:get('savepoint', {level='studyroom', name='main'})
  Gamestate.switch(point.level, point.name)
end

function autosave_warning:keypressed(button)
  Timer.clear()
  self:startGame()
end

function autosave_warning:update(dt)
  self.savingAnimation:update(dt)
end

return autosave_warning
