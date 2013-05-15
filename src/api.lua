local middle = require "hawk/middleclass"
local json = require "hawk/json"
local http = require "socket.http"

local baseurl = "http://api.projecthawkthorne.com"

local api = {}

function api.report(message, tags)
  r, c, h = http.request {
    method = "POST",
    url = baseurl .. "/errors",
    headers = { ["content-type"] = "applicaton/json" },
    body = json.encode({ ["message"] = message, ["tags"] = tags }),
  }
end

return api
