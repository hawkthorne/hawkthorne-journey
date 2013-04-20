local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'
local enemy = require 'nodes/enemy'

local DropBear = {}
DropBear.__index = DropBear

function DropBear.new( node, collider )
    local dropbear = {}
    setmetatable(dropbear, DropBear)

    dropbear.node = node
    dropbear.collider = collider
    dropbear.width = 48
    dropbear.height = 48
    dropbear.dropped = false

    return dropbear
end

function DropBear:enter()
    self.floor = gamestate.currentState().map.objectgroups.block.objects[1].y - self.height
end

function DropBear:update(dt, player)
    if not self.dropped then
        local playerdistance = math.abs(player.position.x - self.node.x) - self.width/2 - player.bbox_width/2
        if playerdistance <= 36 then
            sound.playSfx( 'hippy_enter' )

            local level = gamestate.currentState()
            local node = enemy.new( self.node, self.collider, 'dropbear' )
            level:addNode(node)
            self.dropbear = node

            self.dropbear.position = {x=self.node.x + 12, y=self.node.y}
            self.dropbear.velocity.y = 30

            self.dropped = true
        end
    end
end

function DropBear:draw()
    if not self.dropped then return end
end

return DropBear
