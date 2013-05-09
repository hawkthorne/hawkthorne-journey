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
  self._next = nil
end

function Application:setScene(scene)
  self._next = scene
end

function Application:draw()
  if self.scene then self.scene:draw() end
end

function Application:update(dt)
  dt = math.min(0.033333333, dt)

  if self._next ~= nil then
    self.scene = self._next
    self._next = nil
  end

  if self.scene then self.scene:update(dt) end
end

function Application:keypressed(k)
  if self.scene then self.scene:keypressed(k) end
end

function Application:keyreleased(k)
  if self.scene then self.scene:keyreleased(k) end
end

return {
  ["newApplication"] = Application
}
