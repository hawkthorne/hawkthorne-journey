local app = require 'app'

local sparkle = require 'hawk/sparkle'
local middle = require 'hawk/middleclass'

local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'

local window = require 'window'

local screen = Gamestate.new()

function screen:init()
  self.message = ""
  self.progress = 0
  self.updater = sparkle.newUpdater(app.config.iteration or "0.0.0",
                                    app.config.feedurl or "")

  self.head = love.graphics.newImage('images/cornelius_head.png')
  local g = anim8.newGrid(144, 192, self.head:getWidth(), self.head:getHeight())
  self.anim = anim8.newAnimation('loop', g('1,1', '2,1', '3,1', '2,1', '1,1'), 0.15)
end

function screen:enter()
  self.updater:start()
end

function screen:update(dt)
  self.anim:update(dt)

  if not self.updater:done() then
    local msg, percent = self.updater:progress()

    if msg ~= "" then
      self.message = msg
      self.progress = (percent or 0) % 100
    end

    return
  end

  Gamestate.switch('splash')
end

function screen:leave()
end

function screen:keypressed(button)
end

function screen:draw()
  self.anim:draw(self.head, window.width / 2 - 144 / 2,
                 window.height / 10)

  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("line", 40, window.height - 100, window.width - 80, 10)
  love.graphics.rectangle("fill", 40, window.height - 100, 
                          (window.width - 80) * self.progress / 100, 10)
  love.graphics.printf(self.message, 40, window.height - 80,
                       window.width - 80, 'center')
end

return screen
