local json = require 'hawk/json'

local datastore = {}
datastore.__index = datastore

function datastore.load(namespace)
  local db = {}
  setmetatable(db, datastore)

  db.path = namespace .. ".json"

  if not love.filesystem.exists(db.path) then 
    love.filesystem.write(db.path, json.encode({}))
  end

  local contents, _  = love.filesystem.read(db.path)
  db.cache = json.decode(contents)

  return db
end


function datastore:get(key, default)
  value = self.cache[key]

  if value == nil then
    return default
  end

  return value
end

function datastore:set(key, value)
  self.cache[key] = value
end

-- Save the contents of the datastore to disk
function datastore:flush()
  love.filesystem.write(self.path, json.encode(self.cache))
end

return datastore
