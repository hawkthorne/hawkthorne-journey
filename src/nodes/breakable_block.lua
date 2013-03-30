local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local Wall = {}
Wall.__index = Wall

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    wall.node = node
    wall.collider = collider
    collider:setPassive(wall.bb)
    wall.isSolid = true
    wall.hp = node.properties.hp or 1
    wall.sprite = love.graphics.newImage(node.properties.sprite)
    local g = anim8.newGrid(24, 24, wall.sprite:getWidth(), wall.sprite:getHeight())
    wall.image = anim8.newAnimation('once', g('1,1'), 1)
    local frames = math.floor(wall.sprite:getWidth()/24)
    wall.destroy = anim8.newAnimation('once', g(frames..',1'), .1)
    wall.dead = false
    wall.dyingdelay = 0.1
    wall.disappear = frames > 1 and false or true

    return wall
end

function Wall:collide( node, dt, mtv_x, mtv_y, bb)
    bb = bb or node.bb
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
        -- bouncing off bottom
        node:ceiling_pushback(self, node.position.y + mtv_y)
    end
    
    if mtv_y < 0 and (not node.isPlayer or bb == node.bottom_bb) then
        -- standing on top
        node:floor_pushback(self, self.node.y - node.height)
    end

end

function Wall:collide_end( node ,dt )
end

function Wall:hurt( damage )
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.dead = true
        self:draw()
        Timer.add(self.dyingdelay, function() if self.disappear then self:die() end end)
    end
end
function Wall:die()

    self.collider:remove(self.bb)
    if self.containerLevel then
      self.containerLevel:removeNode(self)
    end
end

function Wall:draw()
    if self.dead then
        self.destroy:draw(self.sprite, self.node.x, self.node.y)
    else
        self.image:draw(self.sprite, self.node.x, self.node.y)
    end
end

return Wall
