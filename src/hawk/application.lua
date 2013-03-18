local json = require 'hawk/json'

local application = {}
application.__index = application

function application.new(configurationPath)
  local app = {}
  setmetatable(app, application)

  assert(love.filesystem.exists(configurationPath), "Can't read app configuration")
  
  local contents, _  = love.filesystem.read(configurationPath)
  app.config = json.decode(contents)

  return app
end

return application
