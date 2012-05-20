local anim8 = require 'vendor/anim8'

local game = {}

Player = {}
Player.__index = Player

function Player.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local plyr = {}
    local g = anim8.newGrid(92, 92, sheet:getWidth(), sheet:getHeight())

    setmetatable(plyr, Player)
    plyr.sheet = sheet
    plyr.direction = 'right'
    plyr.pos = {x=300, y=450}
    plyr.state = 'idle'
    plyr.dirty = false
    plyr.animations = {
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return plyr
end

function Player:animation()
    return self.animations[self.state][self.direction]
end

function Player:transition(state)
    self.state = state
end

function Player:draw()
    self:animation():draw(self.sheet, self.pos.x, self.pos.y)
end

function Player:reset(direction)
    self.animations['walk'][direction]:gotoFrame(1)
end

function Player:update(dt)
    if self.direction == 'left' and self.state == 'walk' then
        self.pos.x = self.pos.x - 3
    elseif self.direction == 'right' and self.state == 'walk' then
        self.pos.x = self.pos.x + 3
    end
    self:animation():update(dt)
end

function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")

    player = Player.create("images/abed_sheet.png")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

end

function game.update(dt)
    player:update(dt)
end

function game.keyreleased(key)
    if (key == "left" or key == "right") then
        player:transition('idle')
        player:reset(key)
    end
end

function game.keypressed(key)
    if (key == "left" or key == "right") then
        player.direction = key
        player:transition('walk')
    end
end


function game.draw()
    love.graphics.draw(bg)
    player:draw()
end


return game
