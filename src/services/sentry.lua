require "src/utils"

local middle = require "hawk/middleclass"
local json = require "hawk/json"
local url = require "socket.url"

local sentry = {}

function sentry.uuid()
  local template ='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

function sentry.parseDSN(uri)
  local parsed = url.parse(uri)

  local parts = split(parsed.path, "/")
  local project = table.remove(parts)
  local path = "/" .. join(parts, "/") .. "/"

  return {
    uri = parsed.scheme .. "://" .. parsed.host .. path,
    public = parsed.user,
    secret = parsed.password,
    project = project,
  }, nil
end

local RavenClient = middle.class("RavenClient")

function RavenClient:initialize(dsn)
  self.inactive = dsn == ''
end

function RavenClient:captureException(exception, opts)
  if self.inactive then
    return nil
  end
end

function RavenClient:payload(exception, opts)
  return {
    project = dsn.project,
  }
end


sentry.newClient = RavenClient

return sentry
