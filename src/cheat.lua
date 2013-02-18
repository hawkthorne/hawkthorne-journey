local Cheat = {}

local cheatList ={}

--if turnOn is true the cheat is enabled
-- if turnOn is false the cheat is disabled
local function setCheat(cheatName, turnOn)
    local Player = require 'player'
    if cheatName=="jump_high" then
        cheatList[cheatName] = turnOn
        Player.jumpFactor = cheatList[cheatName] and 1.44 or 1
    elseif cheatName=="super_speed" then
        cheatList[cheatName] = turnOn
        Player.speedFactor = cheatList[cheatName] and 2 or 1
    elseif cheatName=="god" then
        cheatList[cheatName] = turnOn
    end
end

function Cheat:is(cheatName)
    return cheatList[cheatName] and true or false
end

function Cheat:on(cheatName)
    setCheat(cheatName,true)
end

function Cheat:off(cheatName)
    setCheat(cheatName,false)
end

function Cheat:toggle(cheatName)
    setCheat(cheatName,not cheatList[cheatName])
end

return Cheat
