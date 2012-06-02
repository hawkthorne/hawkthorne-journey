local Gamestate = require 'vendor/gamestate'
local game = require 'game'
local window = require 'window'
local state = Gamestate.new()

local selections = {
    {name='Alien', filename='characters/abed_alien'},
    {name='Batman', filename='characters/abed_batman'},
    {name='Brittasaurus Rex', filename='characters/britta_dino'},
    {name='Captain Kirk', filename='characters/pierce_kirk'},
    {name='David Beckham', filename='characters/jeff_david'},
    {name='Joey', filename='characters/abed_white'},
    {name='Seacrest Hulk', filename='characters/jeff_hulk'},
    {name='Sexy Vampire', filename='characters/troy_sexyvampire'},
}

function state:init()
    self.screen = love.graphics.newImage("images/pause.png")
    self.arrow = love.graphics.newImage("images/arrow.png")
end

function state:enter(previous)
    self.level = 0
    self.start = 0
    self.previous = previous
end

function state:keypressed(key)
    if key == 'up' or key == 'w' then
        if self.level == 0 then
            self.start = math.max(self.start - 1, 0)
        end
        self.level = math.max(self.level - 1, 0)
    elseif key == 'down' or key == 's' then
        if self.level == 4 then
            self.start = math.min(self.start + 1, (# selections) - 5)
        end
        self.level = math.min(self.level + 1, 4)
    end

    if key == 'return' then
        local selection = selections[self.start + self.level + 1]
        local character = require(selection.filename)
        Gamestate.switch(game, character)
    end

    if key == 'escape' then
        Gamestate.switch(self.previous)
    end
end

function state:draw()
    love.graphics.draw(self.screen)
    love.graphics.draw(self.arrow, 120, 72 + 24 * self.level)
    love.graphics.printf("Press Enter", 0,
        window.height - 40, window.width, 'center')
    love.graphics.printf("Additional Characters", 0,
        20, window.width, 'center')

    for i=1,5,1 do
        local selection = selections[self.start + i]
        if selection then
            love.graphics.print(selection.name, 162, 77 + 24 * (i - 1))
        end
    end
end

return state
