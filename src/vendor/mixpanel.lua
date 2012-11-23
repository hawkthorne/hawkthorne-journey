require "vendor/json"

local mixpanel = {}
local thread = nil
local token = nil

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
  data.version = "v0.0.63"

  thread:set("point", json.encode({event=event, properties=data}))
end

return mixpanel
