local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local fonts = require 'fonts'
local state = Gamestate.new()

local nextState = 'menu'
local nextPlayer = nil

local queue = {}
local current_preload = {}
current_preload.order = 1
current_preload.position = 1
current_preload.keys = {}
current_preload.current_key = 0

function state:init()
    state.finished = false
    state.current = 1
    state.total_assets = 0

    require 'levels'

end

function state:update(dt)
    if self.finished then
        return
    end

    self:iterate()
    local current = self:get_current()
    if current[1] and current[2] and current[3] then
        self.current = self.current + 1
        --callback(       key,      value)
        current[3](current[1], current[2])
    else
        self.finished = true
        self:switch()
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
    if not queue[order] then
        queue[order] = {}
    end

    local preload_item = {}
    preload_item.data = input_table
    preload_item.callback = callback

    -- Insert preload data in queue at proper order
    table.insert(queue[order], preload_item)

    -- Increase total asset count
    local asset_increase = 0
    for _, _ in pairs(input_table) do
        asset_increase = asset_increase + 1
    end
    self.total_assets = self.total_assets + asset_increase
end

function state:iterate()
    if current_preload.current_key == 0 then
        self:populate_current_table()
        return
    end
    current_preload.current_key = current_preload.current_key + 1
    if current_preload.keys[current_preload.current_key] then
        return
    end
    current_preload.position = current_preload.position + 1
    if self:get_current_table() then
        self:populate_current_table()
        return
    end
    current_preload.order = current_preload.order + 1
    current_preload.position = 1
    if self:get_current_table() then
        self:populate_current_table()
        return
    end
end

function state:populate_current_table()
    current_preload.current_key = 1
    current_preload.keys = {}
    for key, _ in pairs(self:get_current_table()) do
        table.insert(current_preload.keys, key)
    end
end

function state:get_current_callback()
    if not queue[current_preload.order] or not queue[current_preload.order][current_preload.position] then
        return nil
    end
    return queue[current_preload.order][current_preload.position]['callback']
end

function state:get_current_table()
    if not queue[current_preload.order] or not queue[current_preload.order][current_preload.position] then
        return nil
    end
    return queue[current_preload.order][current_preload.position]['data']
end

function state:get_current()
    local current_key = current_preload.keys[current_preload.current_key]
    local current_table = self:get_current_table()
    local current_callback = self:get_current_callback()

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
