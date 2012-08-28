local Gamestate = require 'vendor/gamestate'
local Level = require 'level'
local window = require 'window'
local background = require 'selectbackground'
local state = Gamestate.new()

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


local main_selections = {}
main_selections[0] = {}
main_selections[1] = {}
main_selections[1][0] = Wardrobe.create(require 'characters/troy')
main_selections[1][1] = Wardrobe.create(require 'characters/shirley')
main_selections[1][2] = Wardrobe.create(require 'characters/pierce')
main_selections[0][0] = Wardrobe.create(require 'characters/jeff')
main_selections[0][1] = Wardrobe.create(require 'characters/britta')
main_selections[0][2] = Wardrobe.create(require 'characters/abed')
main_selections[0][3] = Wardrobe.create(require 'characters/annie')

local alt_selections = {}
alt_selections[0] = {}
alt_selections[1] = {}
alt_selections[1][0] = Wardrobe.create(require 'characters/fatneil')
alt_selections[1][1] = Wardrobe.create(require 'characters/chang')
alt_selections[1][2] = Wardrobe.create(require 'characters/vicedean')

local main_selected = true
local selections = main_selections

function state:init()
    self.side = 0 -- 0 for left, 1 for right
    self.level = 0 -- 0 through 3 for characters
    self.screen = love.graphics.newImage("images/selectscreen.png")
    self.arrow = love.graphics.newImage("images/arrow.png")
    self.tmp = love.graphics.newImage('images/jeff.png')

    background.load()
end

function state:enter(previous)
    self.previous = previous
    self.music = love.audio.play("audio/opening.ogg", "stream", true)
end

function state:wardrobe()
    return selections[self.side][self.level]
end

function state:keypressed(key)
    local level = self.level
    local options = 4

    if key == 'left' or key == 'right' or key == 'a' or key == 'd' then
        self.side = (self.side - 1) % 2
    elseif key == 'up' or key == 'w' then
        level = (self.level - 1) % options
    elseif key == 'down' or key == 's' then
        level = (self.level + 1) % options
    end

    if key == 'tab' then
        if self.level == 3 and self.side == 1 then
            return
        elseif love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            local wardrobe = self:wardrobe()
            if wardrobe then
                wardrobe:prevCostume()
            end
        else
            local wardrobe = self:wardrobe()
            if wardrobe then
                wardrobe:nextCostume()
            end
        end
        return
    end

    self.level = level

    if key == 'escape' then
        Gamestate.switch('home')
        return
    end
    
    if key == 'return' and self.level == 3 and self.side == 1 then
        if main_selected then
            selections = alt_selections
            main_selected = false
        else
            selections = main_selections
            main_selected = true
        end
    elseif key == 'return' then
        local wardrobe = self:wardrobe()

        if wardrobe then
            local level = Gamestate.get('overworld')
            level:reset()
            Gamestate.switch('overworld', wardrobe:newCharacter())
        end
    end
end

function state:leave()
    love.audio.stop(self.music)
end

function state:update(dt)
    background.update(dt)
end

function state:draw()
    -- love.graphics.draw(self.screen)
    background.draw()

    local x = 17
    local r = 0
    local offset = 68

    if self.side == 1 then
        x = window.width - 17
        r = math.pi
        offset = 68 + self.arrow:getHeight()
    end

    local name = ""

    if self:wardrobe() then
        local costume = self:wardrobe():getCostume()
        name = costume.name
    end

    love.graphics.draw(self.arrow, x, offset + 34 * self.level, r)
    love.graphics.printf("Enter to start", 0,
        window.height - 55, window.width, 'center')
    love.graphics.printf("Tab to switch costume", 0,
        window.height - 35, window.width, 'center')

    love.graphics.printf(name, 0,
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

