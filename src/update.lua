local app = require 'app'

local sparkle = require 'hawk/sparkle'
local middle = require 'hawk/middleclass'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'

local screen = Gamestate.new()

function screen:init()
  self.updater = sparkle.newUpdater(app.config.iteration or "0.0.0",
                                    app.config.feedurl or "")

end

function screen:enter()
  self.message = ""
  self.progress = 0
  self.time = 0
  self.logo = love.graphics.newImage('images/menu/splash.png')
  self.bg = sound.playMusic("ending")
  self.updater:start()
end

function screen:update(dt)
  self.time = self.time + dt

  if not self.updater:done() then
    local msg, percent = self.updater:progress()

    if msg ~= "" then
      self.message = msg
      self.progress = (percent or 0) % 100
    end

    return
  end

  if self.time < 2.5 then
    return
  end

  Gamestate.switch('welcome')
end

function screen:leave()
  self.logo = nil
  love.graphics.setColor(255, 255, 255, 255)
end

function screen:keypressed(button)
end

function screen:draw()
  love.graphics.setColor(255, 255, 255, math.min(255, self.time * 100))
  love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth() / 2,
                     window.height / 2 - self.logo:getHeight() / 2)

  if self.progress > 0 then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", 40, window.height - 75, window.width - 80, 10)
    love.graphics.rectangle("fill", 40, window.height - 75, 
                            (window.width - 80) * self.progress / 100, 10)
    love.graphics.printf(self.message, 40, window.height - 55,
                         window.width - 80, 'center')
  end
end

return screen
