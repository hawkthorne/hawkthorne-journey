local middle = require 'hawk/middleclass'
local json = require 'hawk/json'
local i18n = require 'hawk/i18n'
local gamesave = require 'hawk/gamesave'

local Application = middle.class('Application')

function Application:initialize(configurationPath)
  assert(love.filesystem.exists(configurationPath), "Can't read app configuration")
  
  local contents, _  = love.filesystem.read(configurationPath)
  self.config = json.decode(contents)

  self.gamesaves = gamesave(3)
  self.i18n = i18n("locales")
end

return Application
