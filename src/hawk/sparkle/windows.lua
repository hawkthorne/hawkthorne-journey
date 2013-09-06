require "utils"

local os = require "os"
local url = require "socket.url"
local urllib = require "hawk/sparkle/urllib"

local windows = {}


local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function execute(command, msg)
  local code = os.execute(command)
    
  if code ~= 0 then
    error(msg)
  end
end

function windows.getApplicationPath(workingdir)
  if love._exe then
    return ""
  end
  return workingdir
end

function windows.getDownload(item)
  local cwd = love.filesystem.getWorkingDirectory()
  local exe = cwd .. "/amd64"

  local arch = file_exists(exe) and "amd64" or "i386"

  for i, platform in ipairs(item.platforms) do
    if platform.name == "windows" and platform.arch == arch then
      return platform
    end
  end

  return nil
end

function windows.basename(link)
  local parsed_url = url.parse(link)
  local parts = split(parsed_url.path, "/")
  return table.remove(parts)
end

function windows.replace(download, cwd, callback)
  -- Remove old items
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    os.remove("old_" .. base)
  end

  -- Download new files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    urllib.retrieve(file.url, "new_" .. base, file.length, callback)
  end

  -- Rename current files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    if file_exists(base) then
      os.rename(base, "old_" .. base)
    end
  end

  -- Move new files into place
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    os.rename("new_" .. base, base)
  end

  os.execute("cmd /C start .\\hawkthorne.exe")
end

return windows
