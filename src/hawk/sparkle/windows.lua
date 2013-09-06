require "utils"

local http = require "socket.http"
local ltn12 = require "ltn12"
local os = require "os"
local url = require "socket.url"

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
  local arch = "i386"

  -- This is a bit complicated, but we check the size of SDL.ddl
  -- to figure out if what architecture we're using, defaulting
  -- to 32 bit (i836)
  local cwd = love.filesystem.getWorkingDirectory()
  local dll = cwd .. "\\SDL.dll"
  local f = io.open(dll, "r")

  if f ~= nil then 
    if (f:seek("end") or 0) > 380000 then
      arch = "amd64"
    end
    io.close(f)
  end

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

function windows.replace(download, oldpath, callback)
  local cwd = love.filesystem.getWorkingDirectory()

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

  for _, item in ipairs(download.files) do
    local path = cwd .. "\\" .. windows.basename(item.url) 
    local f = io.open(path, "w")

    local r, c, h = http.request{
      url = item.url,
      sink = monitor(ltn12.sink.file(f), item.length)
    }
  end

  return true
end

function windows.restart(path)
  -- Nothing yet
end

return windows
