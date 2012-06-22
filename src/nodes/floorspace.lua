local Floorspace = {}
Floorspace.__index = Floorspace

function Floorspace.new(node, collider)
    local floor = {}
    setmetatable(floor, Floorspace)
    floor.miny = node.y
    floor.maxy = node.y + node.height
    floor.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    floor.bb.node = floor
    floor.bb:move(0, tonumber(node.properties.offset or 0))

    collider:setPassive(floor.bb)

    return floor
end

function Floorspace:update(dt, player)
    if player.jumping then
        return
    end

    local _, wy1, _, _  = self.bb:bbox()

    local moveDown = (love.keyboard.isDown('down') or love.keyboard.isDown('s'))
    local moveUp = (love.keyboard.isDown('up') or love.keyboard.isDown('w'))

    if moveDown and wy1 <= self.maxy and not player.blocked_down then
        self.bb:move(0, dt * 100)
    elseif moveUp and wy1 >= self.miny and not player.blocked_up then
        self.bb:move(0, dt * -100)
    end

	player.plane = wy1
end

function Floorspace:collide(player, dt, mtv_x, mtv_y)
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, py1, _, py2 = player.bb:bbox()

    if player.velocity.y >= 0 then --and math.abs(wy1 - py2) <= distance then
        player.velocity.y = 0
        player.position.y = wy1 - player.height -- fudge factor
        player:moveBoundingBox()

        player.jumping = false
        player.rebounding = false
    end
end

return Floorspace
