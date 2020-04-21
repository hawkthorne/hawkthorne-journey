local http = require "socket.http"
local ltn12 = require "ltn12"

local baseurl = "http://api.projecthawkthorne.com"
local channel = love.thread.getChannel("mixpanel")

while true do
  local payload = channel:demand()
  http.request {
    method = "POST",
    url = baseurl .. "/metrics",
    headers = { ["content-type"] = "application/json", ["content-length"] = tostring(payload:len()) },
    source = ltn12.source.string(payload),
  }
end
