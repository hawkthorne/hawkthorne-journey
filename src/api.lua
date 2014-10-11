local middle = require "hawk/middleclass"
local json = require "hawk/json"
local http = require "socket.http"
local ltn12 = require "ltn12"

local baseurl = "http://api.projecthawkthorne.com"

local api = {}

function api.report(message, tags)
  local msg = string.gsub(message, "\'", "\"")

  local payload = json.encode({ ["message"] = msg, ["tags"] = tags })
  return http.request {
    method = "POST",
    url = baseurl .. "/errors",
    headers = { ["content-type"] = "application/json", ["content-length"] = tostring(payload:len()) },
    source = ltn12.source.string(payload),
  }
end

function api.track(payload)
  return http.request {
    method = "POST",
    url = baseurl .. "/metrics",
    headers = { ["content-type"] = "application/json", ["content-length"] = tostring(payload:len()) },
    source = ltn12.source.string(payload),
  }
end

return api
