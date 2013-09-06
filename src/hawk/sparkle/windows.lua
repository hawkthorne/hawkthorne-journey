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
  local cwd = love.filesystem.getWorkingDirectory()
  local exe = cwd .. "\\update64.exe"

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

function windows.replace(zipfile, oldpath)
  return true
end

function windows.restart(zipfile, path)
  local cwd = love.filesystem.getWorkingDirectory()
  local save = love.filesystem.getSaveDirectory()
  local exe = cwd .. "\\update64.exe"
  local cmd = file_exists(exe) and "update64.exe" or "update32.exe"
  os.execute(string.format("cmd /C start /min .\\%s \"%s\" \"%s\" \"%s\"",
                           cmd, path, zipfile, save))
end

return windows
