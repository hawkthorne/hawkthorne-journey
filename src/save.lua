local app = require 'app'

local save = {}

function save:saveGame(_level, _door)
	local gamesave = app.gamesaves:active()
	local point = gamesave:get('savepoint')
	if point ~= null and (_level.name == point.level and _door == point.name) or app.config.hardcore then return end
	_level.hud:startSave()
    gamesave:set('savepoint', {level=_level.name, name=_door})
    local player = _level.player
    player:saveData(gamesave)
    gamesave:flush()
	_level.hud:endSave()
end

return save