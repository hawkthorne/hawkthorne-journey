local http = require("socket.http")
local mime = require("mime")

local thread = love.thread.getThread()

while true do
  local point = mime.b64(thread:demand("point"))
  local url = "http://api.mixpanel.com/track/?data=" .. point .. "&ip=1"
  local b, c, h = http.request(url)
end
