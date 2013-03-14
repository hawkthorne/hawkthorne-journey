local json = require 'hawk/json'

local mixpanel = {}
local thread = nil
local token = nil
local version = split(love.graphics.getCaption(), "v")[2]

function mixpanel.init(t)
  thread = love.thread.newThread("mixpanel", "vendor/mixpanel_thread.lua")
  thread:start()
  token = t
end

function mixpanel.track(event, data)
  assert(thread, "Can't find the mixpanel thread")
  assert(token, "Need a token to send to mixpanel")

  local data = data or {}
  data.token = token
  data.version = version

  thread:set("point", json.encode({event=event, properties=data}))
end

return mixpanel
