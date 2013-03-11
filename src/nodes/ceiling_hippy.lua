local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'
local enemy = require 'nodes/enemy'

local CeilingHippie = {}
CeilingHippie.__index = CeilingHippie

local open_ceiling = love.graphics.newImage('images/open_ceiling.png')
local broken_tiles = love.graphics.newImage('images/broken_tiles.png')

function CeilingHippie.new( node, collider )
    local ceilinghippie = {}
    setmetatable(ceilinghippie, CeilingHippie)
    
    ceilinghippie.node = node
    ceilinghippie.collider = collider
    ceilinghippie.width = 48
    ceilinghippie.height = 48
    ceilinghippie.dropped = false
    
    return ceilinghippie
end

function CeilingHippie:enter()
    self.floor = gamestate.currentState().map.objectgroups.block.objects[1].y - self.height
end

function CeilingHippie:update(dt, player)
    if not self.dropped then
        if player.position.x + player.bbox_width + 36 >= self.node.x then
            sound.playSfx( 'hippy_enter' )

            local level = gamestate.currentState()
            local node = enemy.new( self.node, self.collider, 'hippy' )
            level:addNode(node)
            self.hippie = node
    
            self.hippie.position = {x=self.node.x + 12, y=self.node.y}
            self.hippie.velocity.y = 300
            
            self.dropped = true
        end
    end
end

function CeilingHippie:draw()
    if not self.dropped then return end
    
    love.graphics.draw( open_ceiling, self.node.x - 24, self.node.y )
    love.graphics.draw( broken_tiles, self.node.x - 24, self.floor + self.node.height * 2 )
end

return CeilingHippie
