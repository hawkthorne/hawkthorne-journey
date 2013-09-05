-- Usage:
--
-- function love.update(dt)
--   if not updater:done() then
--     updater:update(dt)
--     return
--   end
-- end
--
-- function love.draw()
--   if not updater:done() then
--     updater:draw()
--     return
--   end
-- end
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

  local percent = self.thread:get('percent') or 5
  local status = self.thread:get('status')
  local err = self.thread:get('error')

  if err ~= nil then
    return err, percent
  end

  if status ~= nil then
    return status, percent
  end

  if self:done() then
    return "Finished updating", 100
  end

  return "Working", percent
end

local sparkle = {}

function sparkle.newUpdater(version, url)
  return Updater(version, url)
end

-- This method blocks and should never be called directly
-- Instead, use the updater object
-- OSX only for now
function sparkle.update(version, url, callback)
  local callback = callback or function(s, p) end
  local cwd = love.filesystem.getWorkingDirectory()
  local oldpath = osx.getApplicationPath(cwd) 

  if oldpath == "" then
    pcall(callback, "Can't find application directory", 100)
  end

  -- Download appcast
  -- Parse appcast
  -- Compare versions

  local downloadpath = os.tmpname()
  local f = io.open(downloadpath, "w")

  local function step(src, snk)
    local chunk, src_err = src()
    local ret, snk_err = snk(chunk, src_err)
    pcall(callback, "Downloading", string.len(chunk))
    return chunk and ret and not src_err and not snk_err, src_err or snk_err
  end

  r, c, h = http.request{ 
    url = "http://files.projecthawkthorne.com/releases/latest/hawkthorne-osx.zip",
    sink = ltn12.sink.file(f),
    step = step
  }
  
  osx.replace(downloadpath, oldpath)
  osx.restart(oldpath)
end

return sparkle
