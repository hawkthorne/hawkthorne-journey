local os = require "os"
local urllib = require "hawk/sparkle/urllib"

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

function osx.replace(download, oldpath, callback)
  local appname = "Journey to the Center of Hawkthorne.app"
  local destination = love.filesystem.getSaveDirectory()
  local zipfile = destination .. "/game_update_osx.zip"
  local newpath = destination .. "/" .. appname

  local item = download.files[1]

  urllib.retrieve(item.url, zipfile, item.length, callback)

  execute(string.format("rm -rf \"%s\"", newpath),
          string.format("Error removing previously downloaded %s", newpath))

  execute(string.format("unzip -q -d \"%s\" \"%s\"", destination, zipfile),
          string.format("Error unzipping %s", zipfile))

  execute(string.format("rm -rf \"%s\"", oldpath),
          string.format("Error removing previous install %s", oldpath))

  execute(string.format("mv \"%s\" \"%s\"", newpath, oldpath),
          string.format("Error moving new app %s to %s", newpath, oldpath))

  os.remove(zipfile)

  execute(string.format("open \"%s\"", oldpath),
          string.format("Can't open %s", oldpath))
end

return osx
