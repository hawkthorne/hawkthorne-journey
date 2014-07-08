local json = require 'hawk/json'
local middle = require 'hawk/middleclass'

local Datastore = middle.class('Datastore')

function Datastore:initialize(namespace)
  self.path = namespace .. ".json"

  if not love.filesystem.exists(self.path) then 
    love.filesystem.write(self.path, json.encode({}))
  end

  self:refresh()
end

function Datastore:refresh()
  local contents, _  = love.filesystem.read(self.path)
  self._cache = json.decode(contents)
end

function Datastore:get(key, default)
  value = self._cache[key]

  if value == nil then
    return default
  end

  return value
end

function Datastore:delete()
  love.filesystem.write(self.path, json.encode({}))
  self:refresh()
end

function Datastore:set(key, value)
  self._cache[key] = value
end

-- Save the contents of the datastore to disk
function Datastore:flush()
  love.filesystem.write(self.path, json.encode(self._cache))
end

return Datastore
