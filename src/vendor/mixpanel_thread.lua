local http = require("socket.http")

local thread = love.thread.getThread()

while true do
  local url = thread:demand("url")
  local b, c, h = http.request(url)
end
