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

function osx.replace(zipfile, oldpath)
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

function osx.restart(path)
  execute(string.format("open \"%s\"", path),
          string.format("Can't open %s", path))
end

return osx
