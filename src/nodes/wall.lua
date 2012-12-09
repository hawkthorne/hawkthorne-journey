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
    local player = node
    
    local _,_,_,ceil_y = self.bb:bbox()
    local tlx,tly,_,_ = player.top_bb:bbox()
    local _,_,brx,bry = player.bottom_bb:bbox()
    
    player.freeze = false
    if mtv_x ~= 0 and player.wall_pushback then
        -- horizontal block
        player:wall_pushback(self, player.position.x+mtv_x*2)
    elseif tly < ceil_y then
        self.collision_direction = self.collision_direction or player.character.direction
        player.position.x = player.position.x + ( 100 * dt *( self.collision_direction == 'right' and 1 or -1 ) )
        player.freeze = true
    end
    
    if mtv_y < 0 then
        -- standing on top
        player:floor_pushback(self, self.node.y - player.height)
    end
end

function Wall:collide_end( node ,dt )
    self.collision_direction = nil
end

return Wall

