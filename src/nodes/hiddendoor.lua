local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local Gamestate = require 'vendor/gamestate'

local Door = {}
Door.__index = Door

local image = love.graphics.newImage('images/fireplace.png')
local g = anim8.newGrid(48, 48, image:getWidth(), image:getHeight())


 
function Door.new(node, collider)
    local door = {}
    setmetatable(door, Door)
    door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    door.bb.node = door
    door.player_touched = false
    door.level = node.properties.level
    door.reenter = node.properties.reenter
    door.animation = anim8.newAnimation('loop', g('1-2,1'), 0.20)
    door.x = node.x
    door.y = node.y
    door.offset = 12
    collider:setPassive(door.bb)

    return door
end

function Door:switch(player)
    local _, _, _, wy2  = self.bb:bbox()
    local _, _, _, py2 = player.bb:bbox()

    if math.abs(wy2 - py2) > 10 or player.jumping then
        return
    end

    local level = Gamestate.get(self.level)
    local current = Gamestate.currentState()

    if not self.reenter and level.new then
        -- create a new level to go into
        Gamestate.load(self.level, level.new(level.tmx))
    end

    Gamestate.switch(self.level, current.character)
end

function Door:update(dt, player)
    self.animation:update(dt)

    if not self.revealed and player.painting_fixed then
        self.revealed = true
        self.moving = true
        Timer.add(1.5, function() self.moving = false end)
    end

    if self.moving then
        self.offset = self.offset + dt * 25
    end
end

function Door:draw()
    self.animation:draw(image, self.x - self.offset, self.y)
end


function Door:keypressed(key, player)
    if (key == 'up' or key == 'w') and self.revealed and not self.moving then
        self:switch(player)
    end
end

return Door


