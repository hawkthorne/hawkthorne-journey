local http = require "socket.http"
local ltn12 = require "ltn12"
local os = require "os"

local middle = require 'hawk/middleclass'
local json = require 'hawk/json'
local osx = require 'hawk/sparkle/osx'

local Updater = middle.class('Updater')

function Updater:initialize(version, url)
  self.thread = nil
  self.version = version
  self.url = url
  self._finished = url == ""
end

function Updater:done()
  return self._finished
end

-- All paths must be absolute
function Updater:start()
  if self.url == "" then
    return
  end

  if not self.thread then
    self.thread = love.thread.newThread("sparkle", "hawk/sparkle/thread.lua")
    self.thread:start()
    self.thread:set('version', self.version)
    self.thread:set('url', self.url)
  end
end

function Updater:progress()
  if not self.thread then
    return "Waiting to start", 0
  end

  local percent = self.thread:get('percent') or 0
  local status = self.thread:get('status')
  local err = self.thread:get('error')

  if err ~= nil then
    self._finished = true
    return err, percent
  end

  if status ~= nil then
    return status, percent
  end

  if self:done() then
    return "Finished updating", 100
  end

  return "", 0
end

local sparkle = {}

function sparkle.newUpdater(version, url)
  return Updater(version, url)
end

function sparkle.parseVersion(version)
  local a, b, c = string.match(version, '^(%d+)\.(%d+)\.(%d+)$')
  if a == nil or b == nil or c == nil then
    return nil, nil, nil
  end
  return tonumber(a), tonumber(b), tonumber(c)
end

function sparkle.isNewer(version, other)
  -- Assumes that both versions are in the format 0.0.0
  local major1, minor1, fix1 = sparkle.parseVersion(version)
  local major2, minor2, fix2 = sparkle.parseVersion(other)

  if major1 == nil or major2 == nil then
    return false
  end

  if major1 < major2 then
    return true
  end

  if major1 == major2 and minor1 < minor2 then
    return true
  end

  if major1 == major2 and minor1 == minor2 and fix1 < fix2 then
    return true
  end

  return false
end

-- This method blocks and should never be called directly
-- Instead, use the updater object
-- OSX only for now
function sparkle.update(version, url, callback)
  local callback = callback or function(s, p) end
  local cwd = love.filesystem.getWorkingDirectory()
  --local oldpath = osx.getApplicationPath(cwd) 

  local oldpath = "/tmp/Fake.app"

  if oldpath == "" then
    error("Can't find application directory")
  end

  -- Download appcast
  -- Parse appcast
  -- Compare versions

  -- Create temporary download location
  local downloadpath = os.tmpname()
  local f = io.open(downloadpath, "w")

  local function monitor(sink, total)
    local seen = 0
    local wrapper = function(chunk, err)
      if chunk ~= nil then
        seen = seen + string.len(chunk)
        pcall(callback, "Downloading", seen / total * 100)
      end
      return sink(chunk, err)
    end
    return wrapper
  end
  
  -- Download the latest relesae
  r, c, h = http.request{ 
    url = "http://files.projecthawkthorne.com/releases/latest/hawkthorne-osx.zip",
    sink = monitor(ltn12.sink.file(f), 57980508)
  }

  -- Replace the current app with the download application
  osx.replace(downloadpath, oldpath)

  -- Remove the downloaded zip file
  os.remove(downloadpath)

  -- Restart the process
  osx.restart(oldpath)

  -- Quit the current program
  love.event.push("quit")
end

return sparkle
