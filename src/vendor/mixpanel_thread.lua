local http = require "socket.http"
local ltn12 = require "ltn12"

local baseurl = "http://api.projecthawkthorne.com"
local thread = love.thread.getThread()

while true do
  local payload = thread:demand("payload")
  return http.request {
    method = "POST",
    url = baseurl .. "/metrics",
    headers = { ["content-type"] = "application/json", ["content-length"] = tostring(payload:len()) },
    source = ltn12.source.string(payload),
  }
end
