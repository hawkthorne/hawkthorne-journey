local app = require 'app'

local sparkle = require 'hawk/sparkle'

local Gamestate = require 'vendor/gamestate'
local screen    = Gamestate.new()

function screen:init()
  self.message = ""
  self.progress = ""
  self.updater = sparkle.newUpdater(app.iteration or "0.0.0",
                                    "http://files.projecthawkthorne.com/appcast.json")
end

function screen:enter()
  self.updater:start()
end

function screen:update(dt)
  if not self.updater:done() then
    local msg, percent = self.updater:progress()

    if msg ~= "" then
      self.message = msg
      self.progress = percent or 0
    end

    return
  end

  --Gamestate.switch('splash')
end

function screen:leave()
end

function screen:keypressed(button)
end

function screen:draw()
  love.graphics.print(self.message, 10, 10)
  love.graphics.print(self.progress, 20, 20)
end

return screen
