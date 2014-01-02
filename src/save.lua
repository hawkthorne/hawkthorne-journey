local app = require 'app'

local save = {}

function save:saveGame(_level, _door)
	local gamesave = app.gamesaves:active()
	local point = gamesave:get('savepoint')
	if point ~= null and (_level.name == point.level and _door == point.name) then return end
	self:startSaving(_level)
    gamesave:set('savepoint', {level=_level.name, name=_door})
    local player = _level.player
    player:saveData(gamesave)
    gamesave:flush()
    player:refillHealth()
    self:endSaving(_level)
end

function save:startSaving(level)
	print("started saving")
	level.hud:startSave()
end

function save:endSaving(level)
	print("finished saving")
	level.hud:endSave()
end

return save