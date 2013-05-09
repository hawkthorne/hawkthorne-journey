local gamesave = require 'hawk/gamesave'
local i18n = require 'hawk/i18n'
local json = require 'hawk/json'
local middle = require 'hawk/middleclass'
local config = require 'hawk/config'

local Application = middle.class('Application')

function Application:initialize(configurationPath)
  assert(love.filesystem.exists(configurationPath),
         "Can't read app configuration at path: " .. configurationPath)
  
  self.config = config.load(configurationPath)
  self.gamesaves = gamesave(3)
  self.i18n = i18n("locales")
  self.scene = nil
end

function Application:draw()
  if self.scene then scene:draw() end
end

-- if not ( type(love._version) == "string" and love._version >= "0.8.0" ) then

function Application:update(dt)
  dt = math.min(0.033333333, dt)
  if self.scene then scene:update(dt) end
end

function Application:keypressed(k)
  if self.scene then scene:keypressed(k) end
end

function Application:keyreleased()
  if self.scene then scene:keyreleased(k) end
end

return Application
