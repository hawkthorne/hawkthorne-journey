local Gamestate = require 'vendor/gamestate'
local game = require 'game'
local window = require 'window'
local state = Gamestate.new()

local selections = {}
selections[0] = {}
selections[1] = {}
selections[1][0] = require 'characters/troy'
selections[1][1] = require 'characters/shirley'
selections[1][2] = require 'characters/pierce'
selections[0][0] = require 'characters/jeff'
selections[0][1] = require 'characters/britta'
selections[0][2] = require 'characters/abed'
selections[0][3] = require 'characters/annie'

function state:init()
    self.quads = {}
    self.quads[0] = {}
    self.quads[1] = {}

    self.side = 0 -- 0 for left, 1 for right
    self.level = 0 -- 0 through 3 for characters
    self.button = love.graphics.newImage("images/enter.png")
    self.names = love.graphics.newImage("images/names.png")
    self.screen = love.graphics.newImage("images/selectscreen.png")
    self.arrow = love.graphics.newImage("images/arrow.png")
end

function state:currentName()
    if not self.quads[self.side][self.level] then
        local y = self.side * 88 + self.level * 22
        local quad = love.graphics.newQuad(0, y, self.names:getWidth(), 21,
            self.names:getWidth(), self.names:getHeight())
        self.quads[self.side][self.level] = quad
    end
    return self.quads[self.side][self.level]
end

function state:character()
    return selections[self.side][self.level]
end

function state:keypressed(key)
    local level = self.level
    local options = 4

    if self.side == 1 then
        options = 3
    end

    if key == 'left' or key == 'right' or key == 'a' or key == 'd' then
        self.side = (self.side - 1) % 2
    elseif key == 'up' or key == 'w' then
        level = (self.level - 1) % options
    elseif key == 'down' or key == 's' then
        level = (self.level + 1) % options
    end

    if self.side == 1 and level == 3 then
        level = 2
    end

    self.level = level
    
    if key == 'return' then
        local character = self:character()
        Gamestate.switch(game, character)
    end
end

function state:draw()
    love.graphics.draw(self.screen)
    local x = 17
    local r = 0
    local offset = 68

    if self.side == 1 then
        x = window.width - 17
        r = math.pi
        offset = 68 + self.arrow:getHeight()
    end

    love.graphics.draw(self.arrow, x, offset + 34 * self.level, r)
    love.graphics.draw(self.button,
        window.width / 2 - self.button:getWidth() / 2,
        window.height - self.button:getHeight() * 2.5)
    love.graphics.drawq(self.names, self:currentName(),
        window.width / 2 - self.names:getWidth() / 2, 23)
end

Gamestate.home = state

return state

