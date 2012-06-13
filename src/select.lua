local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local state = Gamestate.new()

local music = love.audio.newSource("audio/opening.ogg")
music:setLooping(true)


local Wardrobe = {}
Wardrobe.__index = Wardrobe

function Wardrobe.create(character)
    local drobe = {}
    setmetatable(drobe, Wardrobe)

    drobe.character = character
    drobe.count = 1

    drobe.image = love.graphics.newImage(character.costumes[1].sheet)
    drobe.image:setFilter('nearest', 'nearest')
    drobe.mask = love.graphics.newQuad(0, character.offset, 48, 27,
                                       drobe.image:getWidth(),
                                       drobe.image:getHeight())
    return drobe
end

function Wardrobe:newCharacter()
    local sprite = self.character.new(self.image)
    sprite.ow = self.character.ow
    return sprite
end

function Wardrobe:getCostume()
    return self.character.costumes[self.count]
end

function Wardrobe:prevCostume()
    self.count = (self.count - 1)
    if self.count == 0 then
      self.count = (# self.character.costumes)
    end
    self:loadCostume()
end

function Wardrobe:nextCostume()
    self.count = math.max((self.count + 1) % (# self.character.costumes + 1), 1)
    self:loadCostume()
end

function Wardrobe:loadCostume()
    self.image = love.graphics.newImage(self.character.costumes[self.count].sheet)
    self.mask = love.graphics.newQuad(0, self.character.offset, 48, 27,
                                       self.image:getWidth(),
                                       self.image:getHeight())
end

function Wardrobe:draw(x, y, flipX)
    love.graphics.drawq(self.image, self.mask, x, y, 0, flipX, 1)
end


local selections = {}
selections[0] = {}
selections[1] = {}
selections[1][0] = Wardrobe.create(require 'characters/troy')
selections[1][1] = Wardrobe.create(require 'characters/shirley')
selections[1][2] = Wardrobe.create(require 'characters/pierce')
selections[0][0] = Wardrobe.create(require 'characters/jeff')
selections[0][1] = Wardrobe.create(require 'characters/britta')
selections[0][2] = Wardrobe.create(require 'characters/abed')
selections[0][3] = Wardrobe.create(require 'characters/annie')


function state:init()
    self.side = 0 -- 0 for left, 1 for right
    self.level = 0 -- 0 through 3 for characters
    self.screen = love.graphics.newImage("images/selectscreen.png")
    self.arrow = love.graphics.newImage("images/arrow.png")
    self.tmp = love.graphics.newImage('images/jeff.png')
end

function state:enter(previous)
    self.previous = previous
    love.audio.play(music)
end

function state:wardrobe()
    return selections[self.side][self.level]
end

function state:keypressed(key)
    local level = self.level
    local options = self.side == 0 and 4 or 3

    if key == 'left' or key == 'right' or key == 'a' or key == 'd' then
        self.side = (self.side - 1) % 2
    elseif key == 'up' or key == 'w' then
        level = (self.level - 1) % options
    elseif key == 'down' or key == 's' then
        level = (self.level + 1) % options
    end

    if key == 'tab' then
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            self:wardrobe():prevCostume()
        else
            self:wardrobe():nextCostume()
        end
        return
    end

    self.level = self.side == 1 and level == 3 and 2 or level

    if key == 'escape' then
        Gamestate.switch(Gamestate.title)
        return
    end
    
    if key == 'return' and self.level == 3 and self.side == 1 then
        Gamestate.switch(additional)
    elseif key == 'return' then
        local wardrobe = self:wardrobe()

        local level = Gamestate.get('overworld')
        level:reset()
        Gamestate.switch('overworld', wardrobe:newCharacter())
    end
end

function state:leave()
    love.audio.stop()
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

    local costume = self:wardrobe():getCostume()

    love.graphics.draw(self.arrow, x, offset + 34 * self.level, r)
    love.graphics.printf("Enter to start", 0,
        window.height - 55, window.width, 'center')
    love.graphics.printf("Tab to switch costume", 0,
        window.height - 35, window.width, 'center')
    love.graphics.printf(costume.name, 0,
        23, window.width, 'center')

    for i=0,1,1 do
        for j=0,4,1 do
            local wardrobe = selections[i][j]
            if wardrobe then
                if i == 0 then
                    wardrobe:draw(131 + 48 - 34 * j, 66 + 34 * j, -1)
                else
                    wardrobe:draw(281 + 34 * j, 66 + 34 * j, 1)
                end
            end
        end
    end
end

Gamestate.home = state

return state

