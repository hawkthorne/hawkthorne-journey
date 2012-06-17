local Shelf = {}
Shelf.__index = Shelf

function Shelf.new(node, collider)
    local shelf = {}
    setmetatable(shelf, Shelf)
    shelf.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    shelf.bb.node = shelf
    collider:setPassive(shelf.bb)

    return shelf
end

function Shelf:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, py1, _, py2 = player.bb:bbox()
    local distance = math.abs(player.velocity.y * dt) + 0.10

    if player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance and player.state ~= 'crouch' then
        player.velocity.y = 0
        player.position.y = wy1 - player.height -- fudge factor
        player:moveBoundingBox()

        player.jumping = false
        player.rebounding = false
    -- elseif player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance and player.state == 'crouch' then
	-- player.jumping = true
    end
end

return Shelf

