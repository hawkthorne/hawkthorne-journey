local http = require "socket.http"
local ltn12 = require "ltn12"
local os = require "os"

local osx = {}

local function execute(command, msg)
  local code = os.execute(command .. " > /dev/null 2>&1")
    
  if code ~= 0 then
    error(msg)
  end
end

function osx.getApplicationPath(workingdir)
  local path = workingdir:sub(0, -20)
  if path:find(".app") then
    return path
  end
  return ""
end

function osx.getDownload(item)
  for i, platform in ipairs(item.platforms) do
    if platform.name == "macosx" and platform.arch == "universal" then
      return platform
    end
  end
  return nil
end

function osx.update(download, oldpath, callback)
  -- Create temporary download location
  local downloadpath = os.tmpname()
  local f = io.open(downloadpath, "w")

  -- Remove duplicate code eventually
  local function monitor(sink, total)
    local seen = 0
    local wrapper = function(chunk, err)
      if chunk ~= nil then
        seen = seen + string.len(chunk)
        pcall(callback, false, "Downloading", seen / total * 100)
      end
      return sink(chunk, err)
    end
    return wrapper
  end

  local item = download.files[1]

  -- Download the latest relesae
  local r, c, h = http.request{
    url = item.url,
    sink = monitor(ltn12.sink.file(f), item.length)
  }

  local appname = "Journey to the Center of Hawkthorne.app"
  local destination = love.filesystem.getSaveDirectory()

  local newpath = destination .. "/" .. appname

  execute(string.format("rm -rf \"%s\"", newpath),
          string.format("Error removing previously downloaded %s", newpath))

  execute(string.format("unzip -q -d \"%s\" \"%s\"", destination, downloadpath),
          string.format("Error unzipping %s", downloadpath))

  execute(string.format("rm -rf \"%s\"", oldpath),
          string.format("Error removing previous install %s", oldpath))

  execute(string.format("mv \"%s\" \"%s\"", newpath, oldpath),
          string.format("Error moving new app %s to %s", newpath, oldpath))

  return true
end

function osx.restart(path)
  execute(string.format("open \"%s\"", path),
          string.format("Can't open %s", path))
end

return osx
