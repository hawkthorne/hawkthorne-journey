local http = require "socket.http"
local ltn12 = require "ltn12"
local os = require "os"

local urllib = {}

function urllib.retrieve(url, path, length, callback) 
  local f = io.open(path, "w+b")

  local function monitor(sink, total)
    local seen = 0
    local wrapper = function(chunk, err)
      if chunk ~= nil then
        pcall(function() 
          seen = seen + string.len(chunk)
          callback(false, "Downloading", seen / total * 100)
        end)
      end
      return sink(chunk, err)
    end
    return wrapper
  end

  -- Download the latest relesae
  local r, c, h = http.request{
    url = url,
    sink = monitor(ltn12.sink.file(f), length),
  }
end

return urllib


