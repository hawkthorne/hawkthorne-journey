local json = require 'hawk/json' 
local mime = require 'mime'

local mixpanel = {}
local thread = nil
local token = nil
local version = split(love.graphics.getCaption(), "v")[2]

local function mixpanelUrl(event, data)
  local data = data or {}
  data.token = token
  data.version = version
  local blob = json.encode({event=event, properties=data})
  return "http://api.mixpanel.com/track/?data=" .. mime.b64(blob) .. "&ip=1"
end

local function stathatUrl(event, data)
  return "http://api.stathat.com/ez?ezkey=EsAl1HYhzX9lvmnW&stat=" .. event .. "&count=1"
end


function mixpanel.init(t)
  thread = love.thread.newThread("mixpanel", "vendor/mixpanel_thread.lua")
  thread:start()
  token = t
end

function mixpanel.track(event, data)
  assert(thread, "Can't find the mixpanel thread")
  assert(token, "Need a token to send to mixpanel")

  thread:set("url", mixpanelUrl(event, data))
  thread:set("url", stathatUrl(event, data))
end


return mixpanel
