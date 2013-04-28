local Timer = require 'vendor/timer'
local anim8 = require 'vendor/anim8'
local Wall = {}
Wall.__index = Wall

local crack = love.graphics.newImage('images/blocks/crack.png')

function Wall.new(node, collider)
    local wall = {}
    setmetatable(wall, Wall)
    wall.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    wall.bb.node = wall
    wall.node = node
    wall.collider = collider
    collider:setPassive(wall.bb)
    wall.isSolid = true
    wall.crack = node.properties.crack ~= 'false' and true or false
    
    if node.height > 24 then wall.crack = false end
    
    wall.sprite = love.graphics.newImage('images/blocks/'..node.properties.sprite)
    
    local sprite = wall.crack and crack or wall.sprite
    
    local g = anim8.newGrid(node.width, node.height, sprite:getWidth(), sprite:getHeight())
    
    local frames = math.floor(sprite:getWidth()/node.width)
    
    wall.hp = node.properties.hp or frames
    
    wall.destroyAnimation = anim8.newAnimation('once', g('1-'..frames..',1'), 0.9 / (frames / wall.hp))
    
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
    self.destroyAnimation:update(damage)
    self:draw()
    if self.hp <= 0 then
        self:die()
    end
end
function Wall:die()

    self.collider:remove(self.bb)
    if self.containerLevel then
      self.containerLevel:removeNode(self)
    end
end

function Wall:draw()
    if self.crack then
        love.graphics.draw(self.sprite, self.node.x, self.node.y)
        self.destroyAnimation:draw(crack, self.node.x, self.node.y)
    else
        self.destroyAnimation:draw(self.sprite, self.node.x, self.node.y)
    end
end

return Wall
