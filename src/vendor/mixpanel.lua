local json = require 'hawk/json' 

local mixpanel = {}
local thread = nil
local version = nil

function mixpanel.init(v)
  thread = love.thread.newThread("mixpanel", "vendor/mixpanel_thread.lua")
  thread:start()
  version = v
end

function mixpanel.track(event, data)
  assert(thread, "Can't find the mixpanel thread")
  assert(version, "Need a version to send to mixpanel")

  local data = data or {}

  data["version"] = version
  data["os"] = love._os
  
  local payload = {
    ["metrics"] = {
      { ["event"] = event, ["properties"] = data },
    },
  }

  thread:set("payload", json.encode(payload))
end


return mixpanel
