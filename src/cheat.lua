local Cheat = {}

Cheat.cheatList ={}

-- to test if "cheatName" is enabled, simply use the boolean
--  Cheat.cheatList["cheatName"], this is equivalent to
--  Cheat.cheatList.cheatName
function Cheat:setCheat(cheatName)
    local Player = require 'player'
    if cheatName=="jump_high" then
        self.cheatList[cheatName] = not self.cheatList[cheatName]
        Player.jumpFactor = self.cheatList[cheatName] and 1.44 or 1
    elseif cheatName=="super_speed" then
        self.cheatList[cheatName] = not self.cheatList[cheatName]
        Player.speedFactor = self.cheatList[cheatName] and 2 or 1
    elseif cheatName=="god" then
        self.cheatList[cheatName] = not self.cheatList[cheatName]
    end
end

return Cheat
