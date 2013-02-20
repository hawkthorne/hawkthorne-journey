local Timer = require 'vendor/timer'
local Wall = {}
Wall.__index = Wall

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    wall.node = node
    collider:setPassive(wall.bb)
    wall.isSolid = true

    return wall
end

function Wall:collide( node, dt, mtv_x, mtv_y)
    if not (node.floor_pushback or node.wall_pushback) then return end

    node.bottom_bb = node.bottom_bb or node.bb
    node.top_bb = node.top_bb or node.bb
    local _, wy1, _, wy2 = self.bb:bbox()
    local _, _, _, py2 = node.bottom_bb:bbox()
    local _, py1, _, _ = node.top_bb:bbox()


    if mtv_x ~= 0 and node.wall_pushback and node.position.y + node.height > wy1 + 2 then
        -- horizontal block
        node:wall_pushback(self, node.position.x+mtv_x)
    end

    if mtv_y > 0 and node.ceiling_pushback then
        if mtv_y > 10 and not node.collider._ghost_shapes[node.top_bb] and py1 < wy2 and node.isPlayer then
            if node.unfreeze then Timer.cancel(node.unfreeze) end
            -- node standing up from crouch
            if node.collision_direction == nil then
                node.collision_direction = ( node.character.direction == 'right' and 1 or -1 )
                node.freeze = true
            end
            node.character.state = node.crouch_state
            node.position.x = node.position.x + ( 2 * node.collision_direction )
        else
            -- bouncing off bottom
            node:ceiling_pushback(self, node.position.y + mtv_y)
        end
    end
    
    if mtv_y < 0 and node.velocity.y >= 0 then
        -- standing on top
        node:floor_pushback(self, self.node.y - node.height)
    end

end

function Wall:collide_end( node ,dt )
    if not node.isPlayer then return end
    local player = node
    player.unfreeze = Timer.add(0.2, function() 
        player.collision_direction = nil
        player.freeze = false
    end)
end

return Wall
