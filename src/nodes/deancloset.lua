local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

local Door = {}
Door.__index = Door

local image = love.graphics.newImage('images/dean_closet.png')
local g = anim8.newGrid(48, 65, image:getWidth(), image:getHeight())

function Door.new(node, collider)
    local door = {}
    setmetatable(door, Door)
    door.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    door.bb.node = door
    door.player_touched = false
    door.level = node.properties.level
    door.reenter = node.properties.reenter

    door.animation = anim8.newAnimation('loop', g('1-1,1'), 0.20)


    door.x = node.x
    door.y = node.y
    door.offset = 0
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
        Gamestate.load(self.level, level.new(level.name))
    end

    Gamestate.switch(self.level, current.character)
    player.painting_fixed = false
end

function Door:update(dt, player)
    self.animation:update(dt)
if not self.revealed and player.painting_fixed
    and not self.moving then
        self.revealed = true
        sound.playSfx( 'reveal' )
        self.moving = 1
        Timer.add(1.5, function() self.moving = false end)

    elseif not player.painting_fixed and self.revealed
    and not self.moving then
        self.revealed = false
        sound.playSfx( 'unreveal' )
        self.moving = -1
        Timer.add(1.5, function() self.moving = false end)
    end

    if self.moving then
        self.offset = self.offset + dt * 25 * self.moving
    end
end

function Door:draw()
    self.animation:draw(image, self.x - self.offset, self.y)
end


function Door:keypressed( button, player )
    if button == 'UP' and self.revealed and not self.moving then
        self:switch(player)
    end
end

return Door


