local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local loader = require 'loader'

local levels = {}

loader:preload(
    {
        ['valley']='valley'
    },
    function(key, value)
        print("Preloading " .. key .. " / " .. value)
        levels[key] = Level.new(value)
        Gamestate.load(key, levels[key])
    end)
