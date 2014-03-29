local json = require 'hawk/json' 

local mixpanel = {}
local thread = nil
local channel = nil
local version = nil
local glove = require 'vendor/glove'

local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
"w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6"}


math.randomseed(os.time())

-- Generate a 10-digit random ID
function mixpanel.distinctId()
  if not love.filesystem.exists('mixpanel.txt') then
    love.filesystem.write('mixpanel.txt', mixpanel.randomId())
  end

  local contents, _ = love.filesystem.read('mixpanel.txt')
  return contents
end

-- Generate a 10-digit random ID
function mixpanel.randomId()
  local size = 10
  local pass = {}

  for z = 1,size do
    local case = math.random(1,2)
    local a = math.random(1,#char)
    if case == 1 then
      x=string.upper(char[a])
    elseif case == 2 then
      x=string.lower(char[a])
    end
    table.insert(pass, x)
  end
  return(table.concat(pass))
end

function mixpanel.init(v)
  thread = glove.thread.newThread("mixpanel", "vendor/mixpanel_thread.lua")
  thread:start()
  version = v
end

function mixpanel.track(event, data)
  assert(thread, "Can't find the mixpanel thread")
  assert(version, "Need a version to send to mixpanel")

  local data = data or {}

  data["version"] = version
  data["os"] = love._os
  data["distinct_id"] = mixpanel.distinctId()

  local payload = {
    ["metrics"] = {
      { ["event"] = event, ["properties"] = data },
    },
  }

  thread:set("payload", json.encode(payload))
end


return mixpanel
