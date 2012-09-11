local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local fonts = require 'fonts'
local state = Gamestate.new()

local home = require 'menu'
local nextState = 'home'
local nextPlayer = 'nil'

function state:init()
    state.finished = false
    state.current = 1
    state.assets = {}
    
    fonts.set( 'courier' )

    table.insert(state.assets, function()
        Gamestate.load('valley', Level.new('valley'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('gay-island', Level.new('gay-island'))
    end)

     table.insert(state.assets, function()
        Gamestate.load('gay-island2', Level.new('gay-island2'))
    end)

    table.insert(state.assets, function()
        Gamestate.load('abedtown', Level.new('newtown'))
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
        Gamestate.load('forest2', Level.new('forest2'))
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
        Gamestate.load('deans-office-1', Level.new('deans-office-1'))
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
        Gamestate.load('class-hallway-1', Level.new('class-hallway-1'))
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
        Gamestate.load('gazette-office-1', Level.new('gazette-office-1'))
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
        Gamestate.load('home', require 'menu')
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

    state.step = 240 / # self.assets

    state.messages = {
        "terminal://",
        "operations://load program:(true)",
        "program: journey_to_the_center_of_hawkthorne",
        "loading simulation...",
        "5465415151",
        "5413572495",
        "7342195434",
        "8432159965",
        "3141592653",
        "5897932384",
        "1678942348",
        "1123581321",
        "9437832123",
        "1359756423"
    }
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

function state:draw()
    local progress = (self.current-1) / #self.assets
    local lineCount = math.floor(#self.messages * progress)

    -- Set the color to dark green for the loading font
    love.graphics.setColor(88, 246, 0)
    for i = 1,lineCount do
        -- Draw the first lines larger
        if i <= 4 then
            love.graphics.print(self.messages[i], 50, 15*(i+1), 0, 0.5, 0.5)
        else
            -- Draw the rest of the lines smaller and multiple times
            for j = 1,math.min(lineCount-i+1, 5) do
                love.graphics.print(self.messages[i], 60*j, 15*(i+1), 0, 0.4, 0.4)
            end
        end
    end
    love.graphics.setColor(255, 255, 255)
end

return state
