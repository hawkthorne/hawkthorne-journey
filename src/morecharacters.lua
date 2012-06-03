local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local state = Gamestate.new()

local selections = {
    {name='Alien',
     module='characters/abed',
     sheet='images/abed_alien.png'},
    {name='Batman',
     module='characters/abed',
     sheet='images/abed_batman.png'},
    {name='Brittasaurus Rex',
     module='characters/britta',
     sheet='images/britta_dino.png'},
    {name='Captain Kirk',
     module='characters/pierce',
     sheet='images/pierce_kirk.png'},
    {name='David Beckham',
     module='characters/jeff',
     sheet='images/jeff_david.png'},
    {name='Joey',
     module='characters/abed',
     sheet='images/abed_white.png'},
    {name='Seacrest Hulk',
     module='characters/jeff',
     sheet='images/jeff_hulk.png'},
    {name='Sexy Vampire',
     module='characters/troy',
     sheet='images/troy_sexyvampire.png'},
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
        local character = require(selection.module)
        local level = Level.new(window.level, character.new(selection.sheet))

        love.audio.stop()
        local background = love.audio.newSource("audio/level.ogg")
        background:setLooping(true)
        love.audio.play(background)

        Gamestate.switch(level)
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
