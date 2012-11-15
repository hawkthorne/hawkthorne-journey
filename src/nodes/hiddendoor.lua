local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'

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
    door.animation = anim8.newAnimation('loop', g('1-2,1'), 0.20)
    door.button = node.properties.button and node.properties.button or 'UP'
    door.to = node.properties.to
    door.x = node.x
    door.y = node.y
    door.width = node.width
    door.height = node.height
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

    if not self.reenter and level.new then
        -- create a new level to go into
        Gamestate.load(self.level, level.new(level.name))
    end

    Gamestate.switch(self.level)
    player.painting_fixed = false

    if self.to ~= nil then
        local level = Gamestate.get(self.level)
        assert( level.doors[self.to], "Error! " .. level.name .. " has no door named " .. self.to .. "." )
        local coordinates = {
            x = level.doors[ self.to ].x,
            y = level.doors[ self.to ].y,
        }
        level.player.position = { -- Copy, or player position corrupts entrance data
            x = coordinates.x + self.width / 2 - 24, 
            y = coordinates.y + self.height - 48
        }
    end
    
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
    if button == self.button and self.revealed and not self.moving then
        self:switch(player)
    end
end

return Door


