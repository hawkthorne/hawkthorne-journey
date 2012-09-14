local sound = require 'vendor/TEsound'

local Bouncer = {}
Bouncer.__index = Bouncer

function Bouncer.new(node, collider)
    local bouncer = {}
    setmetatable(bouncer, Bouncer)
    bouncer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    bouncer.bb.node = bouncer
    collider:setPassive(bouncer.bb)

    return bouncer
end

function Bouncer:collide(player)
    sound.playSfx('jump')
    player.velocity.y = -1000
end

return Bouncer
