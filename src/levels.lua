local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local loader = require 'loader'

local levels = {}

-- Actual levels, created with Level.new()
loader:preload(
    {
        ['valley']='valley',
        ['gay-island']='gay-island',
        ['gay-island-2']='gay-island-2',
        ['new-abedtown']='new-abedtown',
        ['abed-castle-interior']='abed-castle-interior',
        ['abed-cave']='abed-cave',
        ['lab']='lab',
        ['house']='house',
        ['studyroom']='studyroom',
        ['hallway']='hallway',
        ['forest']='forest',
        ['forest-2']='forest-2',
        ['black-caverns']='black-caverns',
        ['village-forest']='village-forest',
        ['town']='town',
        ['tavern']='tavern',
        ['blacksmith']='blacksmith',
        ['greendale-exterior']='greendale-exterior',
        ['deans-office']='deans-office',
        ['deans-office-2']='deans-office-2',
        ['deans-closet']='deans-closet',
        ['baseball']='baseball',
        ['dorm-lobby']='dorm-lobby',
        ['borchert-hallway']='borchert-hallway',
        ['admin-hallway']='admin-hallway',
        ['class-hallway']='class-hallway',
        ['class-hallway-2']='class-hallway-2',
        ['rave-hallway']='rave-hallway',
        ['class-basement']='class-basement',
        ['gazette-office']='gazette-office',
        ['gazette-office-2']='gazette-office-2'
    },
    function(key, value)
        --print("Preloading " .. key .. " / " .. value)
        levels[key] = Level.new(value)
        Gamestate.load(key, levels[key])
    end)

-- Interfaces that must be directly required
loader:preload(
    {
        ['overworld']='overworld',
        ['credits']='credits',
        ['select']='select',
        ['menu']='menu',
        ['pause']='pause',
        ['cheatscreen']='cheatscreen',
        ['instructions']='instructions',
        ['options']='options',
        ['blackjackgame']='blackjackgame',
        ['pokergame']='pokergame',
        ['flyin']='flyin'
    },
    function(key, value)
        levels[key] = require(value)
        Gamestate.load(key, levels[key])
    end)
