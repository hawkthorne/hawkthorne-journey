require 'vendor/json'

local datastore = {}
local schema = '1'
local path = 'gamesave-' .. schema .. '.json'


if not love.filesystem.exists(path) then 
    love.filesystem.write(path, json.encode({}))
end

local contents, _  = love.filesystem.read(path)
local cache = json.decode(contents)

function datastore.get(key, default)
    value = cache[key]

    if value == nil then
        return default
    end

    return value
end

function datastore.set(key, value)
    cache[key] = value
    love.filesystem.write(path, json.encode(cache))
end

return datastore
