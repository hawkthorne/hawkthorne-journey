require "love.filesystem"
require "love.event"

local sparkle = require("hawk/sparkle")

local baseurl = "http://api.projecthawkthorne.com"
local thread = love.thread.getThread()

local version = thread:demand('version')
local url = thread:demand('url')

local function statusCallback(status, percent)
  thread:set('status', status)
  thread:set('percent', percent)
end

statusCallback('Hello', 6)

sparkle.update(version, url, statusCallback)

