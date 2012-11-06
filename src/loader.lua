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
    state.total_assets = 0
    state.assets = {}

    require 'levels'

    state.total_assets = state.total_assets + # state.assets
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
            self.current = self.current + 1
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
    local asset_increase = 0
    for _, _ in pairs(input_table) do
        asset_increase = asset_increase + 1
    end
    self.total_assets = self.total_assets + asset_increase
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
                            240 * ( (self.current-1) / self.total_assets ),
                            20)
end

return state
