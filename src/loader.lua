local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local fonts = require 'fonts'
local state = Gamestate.new()

local nextState = 'menu'
local nextPlayer = nil

local preload_queue = {}
local current_preload = {}
current_preload.order = 1
current_preload.position = 1
current_preload.keys = {}
current_preload.current_key = 0

function state:init()
    state.finished = false
    state.current = 1
    state.assets = {}

    require 'levels'

    table.insert(state.assets, function()
        Gamestate.load('gay-island', Level.new('gay-island'))
    end)

     table.insert(state.assets, function()
        Gamestate.load('gay-island-2', Level.new('gay-island-2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('new-abedtown', Level.new('new-abedtown'))
    end)
    
    table.insert(state.assets, function()
        Gamestate.load('abed-castle-interior', Level.new('abed-castle-interior'))
    end)
    
    table.insert(state.assets, function()
        Gamestate.load('abed-cave', Level.new('abed-cave'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('lab', Level.new('lab'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('house', Level.new('house'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('studyroom', Level.new('studyroom'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('hallway', Level.new('hallway'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('forest', Level.new('forest'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('forest-2', Level.new('forest-2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('black-caverns', Level.new('black-caverns'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('village-forest', Level.new('village-forest'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('town', Level.new('town'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('tavern', Level.new('tavern'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('blacksmith', Level.new('blacksmith'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('greendale-exterior', Level.new('greendale-exterior'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('deans-office', Level.new('deans-office'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('deans-office-2', Level.new('deans-office-2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('deans-closet', Level.new('deans-closet'))
    end)
    
    table.insert(state.assets, function()
        Gamestate.load('baseball', Level.new('baseball'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('dorm-lobby', Level.new('dorm-lobby'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('borchert-hallway', Level.new('borchert-hallway'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('admin-hallway', Level.new('admin-hallway'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('class-hallway', Level.new('class-hallway'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('class-hallway-2', Level.new('class-hallway-2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('rave-hallway', Level.new('rave-hallway'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('class-basement', Level.new('class-basement'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('gazette-office', Level.new('gazette-office'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('gazette-office-2', Level.new('gazette-office-2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('overworld', require 'overworld')
    end)

    table.insert(state.assets, function()
        Gamestate.load('credits', require 'credits')
    end)

    table.insert(state.assets, function()
        Gamestate.load('select', require 'select')
    end)

    table.insert(state.assets, function()
        Gamestate.load('menu', require 'menu')
    end)

    table.insert(state.assets, function()
        Gamestate.load('pause', require 'pause')
    end)

    table.insert(state.assets, function()
        Gamestate.load('cheatscreen', require 'cheatscreen')
    end)

    table.insert(state.assets, function()
        Gamestate.load('instructions', require 'instructions')
    end)

    table.insert(state.assets, function()
        Gamestate.load('options', require 'options')
    end)

    table.insert(state.assets, function()
        Gamestate.load('blackjackgame', require 'blackjackgame')
    end)

    table.insert(state.assets, function()
        Gamestate.load('pokergame', require 'pokergame')
    end)

    table.insert(state.assets, function()
        Gamestate.load('flyin', require 'flyin')
    end)

    state.step = 240 / # self.assets
end

function state:update(dt)
    if self.finished then
        return
    end

    local asset = state.assets[self.current]

    if asset ~= nil then
        asset()
        self.current = self.current + 1
    else
        self:preload_iterate()
        local current = self:preload_get_current()
        if current[1] and current[2] and current[3] then
            current[3](current[1], current[2])
        else
            self.finished = true
            self:switch()
        end
    end
end

function state:switch()
    Gamestate.switch(nextState,nextPlayer)
end

function state:target(state,player)
    nextState = state
    nextPlayer = player
end

--- Higher order == loaded later
function state:preload(input_table, callback, order)
    if not order then order = 1 end

    if not preload_queue[order] then
        preload_queue[order] = {}
    end

    local preload_item = {}
    preload_item.data = input_table
    preload_item.callback = callback

    table.insert(preload_queue[order], preload_item)
end

function state:preload_iterate()
    if current_preload.current_key == 0 then
        self:preload_populate_current_table()
        return
    end
    current_preload.current_key = current_preload.current_key + 1
    if current_preload.keys[current_preload.current_key] then
        return
    end
    current_preload.position = current_preload.position + 1
    if self:preload_get_current_table() then
        self:preload_populate_current_table()
        return
    end
    current_preload.order = current_preload.order + 1
    current_preload.position = 1
    if self:preload_get_current_table() then
        self:preload_populate_current_table()
        return
    end
end

function state:preload_populate_current_table()
    current_preload.current_key = 1
    current_preload.keys = {}
    for key, _ in pairs(self:preload_get_current_table()) do
        table.insert(current_preload.keys, key)
    end
end

function state:preload_get_current_callback()
    if not preload_queue[current_preload.order] or not preload_queue[current_preload.order][current_preload.position] then
        return nil
    end
    return preload_queue[current_preload.order][current_preload.position]['callback']
end

function state:preload_get_current_table()
    if not preload_queue[current_preload.order] or not preload_queue[current_preload.order][current_preload.position] then
        return nil
    end
    return preload_queue[current_preload.order][current_preload.position]['data']
end

function state:preload_get_current()
    local current_key = current_preload.keys[current_preload.current_key]
    local current_table = self:preload_get_current_table()
    local current_callback = self:preload_get_current_callback()

    local current_value = nil
    if current_table then
        current_value = current_table[current_key]
    end
    return { 
        current_key,
        current_value,
        current_callback
    }
end

function state:draw()
    love.graphics.rectangle('line', 
                            window.width / 2 - 120,
                            window.height / 2 - 10,
                            240,
                            20)
    love.graphics.rectangle('fill', 
                            window.width / 2 - 120,
                            window.height / 2 - 10,
                            (self.current - 1) * self.step,
                            20)
end

return state
