local Block = {}
Block.__index = Block

function Block.new(node, collider)
    local block = {}
    setmetatable(block, Block)
    block.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    block.bb.node = block
    collider:setPassive(block.bb)

    return block
end

function Block:collide(player, dt, mtv_x, mtv_y)
    local _, blockTop, _, blockBottom = self.bb:bbox()
    local _, _, _, playerBottom = player.bb:bbox()

    player.blocked_down =  math.abs(blockTop - playerBottom) < 1
    player.blocked_up =     playerBottom - blockBottom > 0
		                and playerBottom - blockBottom < 5

    local jumpingUp = player.jumping and player.velocity.y < 0

    if playerBottom < blockTop or playerBottom > blockBottom or jumpingUp then
	    return
    end

    if mtv_y ~= 0 then
        player.velocity.y = 0
        player.position.y = player.position.y + mtv_y
    end

    if mtv_x ~= 0 then
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
    end

	player.jumping = false
end

function Block:collide_end(player, dt)
    player.blocked_up = false
    player.blocked_down = false
end


return Block

