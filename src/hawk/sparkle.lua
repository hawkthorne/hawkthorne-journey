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

local middle = require 'hawk/middleclass'
local json = require 'hawk/json'
local inspect = require 'vendor/inspect'

local Updater = middle.class('Updater')

function Updater:initialize(version, url)
  self.version = version
  self.url = url
  self._finished = url == ""
end

function Updater:done()
  return self._finished
end

function Updater:getApplicationPath(current_os, workingDirectory)
  if current_os == "OS X" then
    local path = workingDirectory:sub(0, -20)
    if path:find(".app") then
      return path
    end
  end
  return ""
end

local function execute(command, msg)
  local code = os.execute(command .. " > /dev/null 2>&1")
    
  if code ~= 0 then
    error(msg)
  end
end


-- All paths must be absolute
function Updater:replace(current_os, zipfile, oldpath)
  if current_os == "OS X" then
    -- This hardcoded value scares me
    local appname = "Journey to the Center of Hawkthorne.app"
    local destination = love.filesystem.getSaveDirectory()

    local newpath = destination .. "/" .. appname

    execute(string.format("rm -rf \"%s\"", newpath),
            string.format("Error removing previously downloaded %s", newpath))

    execute(string.format("unzip -q -d \"%s\" \"%s\"", destination, zipfile),
            string.format("Error unzipping %s", zipfile))

    execute(string.format("rm -rf \"%s\"", oldpath),
            string.format("Error removing previous install %s", oldpath))

    execute(string.format("mv \"%s\" \"%s\"", newpath, oldpath),
            string.format("Error moving new app %s to %s", newpath, oldpath))

    return true
  end

  return error(string.format("Unknown operation system %s", os))
end


function Updater:update()
  local workingdir = love.filesystem.getWorkingDirectory()
  local path = self:getApplicationPath(love._os, workingdir)

  if path == "" then
    return
  end

  -- Check appcast
  -- Download newest release
  local download = "/tmp/foo.txt"

  -- Remove Old

  -- Unzip

  -- Move new
  print(string.format("mv %s %s", download, path))
end

local sparkle = {}

function sparkle.newUpdater(version, url)
  return Updater(version, url)
end

return  sparkle
