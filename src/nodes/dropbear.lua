local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local gamestate = require 'vendor/gamestate'
local enemy = require 'nodes/enemy'

local DropBear = {}
DropBear.__index = DropBear

-- This file represents the DropBear before it has dropped
-- In order to create a proper DropBear, set the node type in the tmx file to 'dropbear' instead of 'enemy'
function DropBear.new( node, collider )
    local dropbear = {}
    setmetatable(dropbear, DropBear)

    dropbear.node = node
    dropbear.collider = collider
    dropbear.width = 48
    dropbear.height = 48
    -- Flag to track whether or not the DropBear has dropped out of the tree or not
    dropbear.dropped = false

    return dropbear
end

-- Node entrance function
function DropBear:enter()
    -- Determine the floor's location
    self.floor = gamestate.currentState().map.objectgroups.block.objects[1].y - self.height
end

function DropBear:update(dt, player)
    if not self.dropped then
        -- Determine if the bear should drop out of the tree
        local playerdistance = math.abs(player.position.x - self.node.x) - (self.width / 2) - (player.bbox_width / 2)
        if playerdistance <= 5 then
            -- TODO: Need a 'roar' sound
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

-- If the bear hasn't dropped yet, short-circuit the drawing process
function DropBear:draw()
    if not self.dropped then
        return
    end
end

return DropBear
