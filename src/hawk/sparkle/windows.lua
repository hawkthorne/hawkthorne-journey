local windows = {}

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function execute(command, msg)
  local code = os.execute(command .. " > /dev/null 2>&1")
    
  if code ~= 0 then
    error(msg)
  end
end

function windows.getApplicationPath(workingdir)
  local path = workingdir:sub(0, -20)
  if path:find(".app") then
    return path
  end
  return ""
end

function windows.getDownload(item)
  local cwd = love.filesystem.getWorkingDirectory()
  local arch = 
  for i, platform in ipairs(item.platforms) do
    if platform.name == "macwindows" and platform.arch == "universal" then
      return platform
    end
  end
  return nil
end

function windows.replace(zipfile, oldpath)
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

function windows.restart(path)
  execute(string.format("open \"%s\"", path),
          string.format("Can't open %s", path))
end

return windows
