require "love.filesystem"

local sprakle = require "hawk/sparkle"

local baseurl = "http://api.projecthawkthorne.com"
local thread = love.thread.getThread()

local version = thread:demand('version')
local url = thread:demand('url')

local function statusCallback(status, percent)
  thread:set('status', status)
  thread:set('percent', percent)
end

sparkle.update(version, url, statusCallback)
