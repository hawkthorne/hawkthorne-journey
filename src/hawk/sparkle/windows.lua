local os = require "os"
local url = require "socket.url"
local urllib = require "hawk/sparkle/urllib"
local utils = require "utils"

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

  for i, platform in ipairs(item.platforms) do
    if platform.name == "windows" then
      return platform
    end
  end

  return nil
end

function windows.basename(link)
  local parsed_url = url.parse(link)
  local parts = utils.split(parsed_url.path, "/")
  return table.remove(parts)
end

-- Remove all files in a directory. The directory must be in the game save
-- folder
function windows.removeRecursive(path)
  if love.filesystem.isFile(path) then
    return love.filesystem.remove(path)
  end

  for k, file in ipairs(love.filesystem.getDirectoryItems(path)) do
    local subpath = path .. "/" .. file

    if love.filesystem.isDirectory(subpath) then
      if not windows.removeRecursive(subpath) then
        return false
      end
    end

    if not love.filesystem.remove(subpath) then
      return false
    end
  end

  return true
end

function windows.cleanup()
  os.remove("old_hawkthorne.exe")
  os.remove("old_love.dll")
  os.remove("old_lua51.dll")
  os.remove("old_mpg123.dll")
  os.remove("old_msvcp110.dll")
  os.remove("old_msvcr110.dll")
  os.remove("old_DevIL.dll")
  os.remove("old_SDL2.dll")
  os.remove("old_OpenAL32.dll")
end

function windows.replace(download, cwd, callback)
  -- Download new files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    urllib.retrieve(file.url, "new_" .. base, file.length, callback)
  end

  -- Rename current files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    os.rename(base, "old_" .. base)
  end

  -- Move new files into place
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    os.rename("new_" .. base, base)
  end

  os.execute("cmd /C start .\\hawkthorne.exe --wait")
end

return windows
