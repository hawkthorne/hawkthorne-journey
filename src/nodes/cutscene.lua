local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'

local Cutscene = {}

Cutscene.__index = Cutscene

function Cutscene.new(node, collider)
    local cutscene = {}
    setmetatable(cutscene, Cutscene)

    cutscene.x = node.x
    cutscene.y = node.y
    cutscene.width = node.width
    cutscene.height = node.height
    
    cutscene.offset = {
        x = -50,
        y = 0
    }
    
    cutscene.looking = 'straight'
    cutscene.state = cutscene.looking
    cutscene.blinkdelay = 0
    cutscene.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds
    
    return cutscene
end

function Cutscene:update(dt, player)
    self.blinkdelay = self.blinkdelay + dt
    if self.blinkdelay >= self.nextblink then
        self.state = 'blink'
        if self.blinkdelay >= self.nextblink + 0.5 then
            self.state = self.looking
            self.nextblink = ( math.random(30) / 10 ) + 2 -- between 2 and 5 seconds
            self.blinkdelay = 0
        end
    elseif player.position.x <= self.x + self.offset.x then
        self.looking = 'left'
        if player.position.y <= self.y + self.offset.y then
            self.looking = 'up_left'
        end
        self.state = self.looking
    elseif player.position.x >= self.x + self.width + self.offset.x then
        self.looking = 'right'
        if player.position.y <= self.y + self.offset.y then
            self.looking = 'up_right'
        end
        self.state = self.looking
    else
        self.looking = 'straight'
        if player.position.y <= self.y + self.offset.y then
            self.looking = 'up'
        end
        self.state = self.looking
    end
end

function Cutscene:draw()
    states[self.state]:draw(image, self.x, self.y)
end

return Cutscene
