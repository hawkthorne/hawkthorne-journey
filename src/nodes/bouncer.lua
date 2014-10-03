local sound = require 'vendor/TEsound'

local Bouncer = {}
Bouncer.__index = Bouncer

function Bouncer.new(node, collider)
    local bouncer = {}
    setmetatable(bouncer, Bouncer)
    bouncer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    bouncer.node = node
    bouncer.bb.node = bouncer
    bouncer.bval = node.properties.bval and -(tonumber(node.properties.bval)) or -1000
    bouncer.dbval = node.properties.dbval and -(tonumber(node.properties.dbval)) or -1500
    collider:setPassive(bouncer.bb)

    return bouncer
end

function Bouncer:collide(node, dt, mtv_x, mtv_y)
    if not node.isPlayer then return end
    local player = node
    
    local player_y = player.position.y + player.character.bbox.height - player.character.bbox.y
    
    if player_y > self.node.y + self.node.height then
        sound.playSfx('jump')
        player.fall_damage = 0
        if self.double_bounce then
            player.velocity.y = self.dbval
        else
            player.velocity.y = self.bval
        end
    end
end

function Bouncer:keypressed( button )
    if button == 'JUMP' then
        self.double_bounce = true
        -- Key has been handled, halt further processing
        return true
    end
end

function Bouncer:collide_end()
    self.bounced = false
    self.double_bounce = false
end

return Bouncer
