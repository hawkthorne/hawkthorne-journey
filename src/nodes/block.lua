local Block = {}
Block.__index = Block

function Block.new(node, collider)
    local block = {}
    setmetatable(block, Block)
    block.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    block.bb.node = block
    block.height = node.height
    block.width = node.width
    block.isSolid = true
    collider:setPassive(block.bb)

    if node.properties and node.properties.image then
        block.image = love.graphics.newImage(node.properties.image)
        block.image:setFilter('nearest', 'nearest')
        block.x = node.x
        block.y = node.y
    end

    return block
end

function Block:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

function Block:collide(node, dt, mtv_x, mtv_y)
    if not node.isPlayer then return end
    local player = node
    
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, _, _, py2 = player.bb:bbox()

    player.blocked_down =  math.abs(wy1 - py2) < 1
    player.blocked_up = py2 - wy2 > 0 and py2 - wy2 < 5

    if py2 < wy1 or py2 > wy2 or player.jumping then
        return
    end

    if mtv_y ~= 0 then
        player.velocity.y = 0
        player.position.y = player.position.y + mtv_y
        player:moveBoundingBox()
    end

    if mtv_x ~= 0 then
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
        player:moveBoundingBox()
    end
end

function Block:collide_end(node, dt)
    if node.isPlayer then
        node.blocked_up = false
        node.blocked_down = false
    end
end


return Block

