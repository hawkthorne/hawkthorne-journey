require "src/utils"

local middle = require "hawk/middleclass"
local url = require "socket.url"

local sentry = {}

sentry.newClient = middle.class("RavenClient")

function sentry.parseDSN(uri)
  local parsed = url.parse(uri)

  local parts = split(parsed.path, "/")
  local project = table.remove(parts)
  local path = "/" .. join(parts, "/") .. "/"

  return {
    uri= parsed.scheme .. "://" .. parsed.host .. path,
    public= parsed.user,
    secret= parsed.password,
    project= project,
  }
end

return sentry
