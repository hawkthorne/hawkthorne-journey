local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'

local Cutscene = {}

Cutscene.__index = Cutscene

function Cutscene.new(name)
    local cutscene = {}
    setmetatable(cutscene, Cutscene)
    return cutscene
end

function Cutscene:update(dt)
end

function Cutscene:draw()
end

return Cutscene
