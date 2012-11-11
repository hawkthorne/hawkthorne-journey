local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'
local Hippie = require 'nodes/hippy'

local CeilingHippie = {}
CeilingHippie.__index = CeilingHippie

local open_ceiling = love.graphics.newImage('images/open_ceiling.png')
local broken_tiles = love.graphics.newImage('images/broken_tiles.png')

function CeilingHippie.new( node, collider )
    local ceilinghippie = {}
    setmetatable(ceilinghippie, CeilingHippie)
    
    ceilinghippie.node = node
    ceilinghippie.width = 48
    ceilinghippie.height = 48
    ceilinghippie.dropped = false
    ceilinghippie.dropspeed = 600

    ceilinghippie.hippie = Hippie.new( node, collider )

    ceilinghippie.position = {x=node.x + 12, y=node.y}

    return ceilinghippie
end

function CeilingHippie:enter()
    self.floor = gamestate.currentState().map.objectgroups.floor.objects[1].y - self.height
end

function CeilingHippie:update(dt, player)
    if not self.dropped then
        if player.position.x + player.bbox_width + 36 >= self.position.x then
            sound.playSfx( 'hippy_enter' )
            self.dropped = true
        end
        return
    end

    if self.hippie.position.y < self.floor then
        self.hippie.position.y = self.hippie.position.y + dt * self.dropspeed
        self.hippie.bb:moveTo(self.hippie.position.x + self.hippie.width / 2,
        self.hippie.position.y + self.hippie.height / 2 + 10)
    else
        self.hippie.position.y = self.floor
    end
    
    self.hippie:update(dt,player)

end

function CeilingHippie:draw()
    if not self.dropped then
        return
    end
    
    love.graphics.draw( open_ceiling, self.node.x - 24, self.node.y )
    love.graphics.draw( broken_tiles, self.node.x - 24, self.floor + self.node.height * 2 )
    
    self.hippie:draw()
end

return CeilingHippie
