local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local state = Gamestate.new()

local home = require 'menu'

function state:init()
    state.finished = false
    state.current = 1
    state.assets = {}

    table.insert(state.assets, function()
        Gamestate.load('lab', Level.new('lab.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('house', Level.new('house.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('studyroom', Level.new('studyroom.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('hallway', Level.new('hallway.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('forest', Level.new('forest2.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('town', Level.new('town.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('tavern', Level.new('tavern.tmx'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('blacksmith', Level.new('blacksmith.tmx'))
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
        Gamestate.load('home', require 'menu')
    end)

    table.insert(state.assets, function()
        Gamestate.load('pause', require 'pause')
    end)

    table.insert(state.assets, function()
        Gamestate.load('instructions', require 'instructions')
    end)

    table.insert(state.assets, function()
        Gamestate.load('options', require 'options')
    end)

    table.insert(state.assets, function()
        Gamestate.load('endscreen', require 'endscreen')
    end)

    table.insert(state.assets, function()
        local font = love.graphics.newImage("imagefont.png")
        font:setFilter('nearest', 'nearest')

        love.graphics.setFont(love.graphics.newImageFont(font,
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/:;%&`'*#=\""), 35)
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
        self.finished = true
        Gamestate.switch('home')
    end
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
