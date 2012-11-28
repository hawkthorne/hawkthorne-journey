local Block = require 'nodes/block'
local controls = require 'controls'

local Floorspace = {}
Floorspace.__index = Floorspace

function Floorspace.new(node, collider)
    local floor = {}
    local offset = tonumber(node.properties.offset or 0)
    setmetatable(floor, Floorspace)
    floor.miny = node.y
    floor.maxy = node.y + node.height
    floor.angled = node.properties.angled == 'true'
    floor.bb = collider:addRectangle(node.x, node.y, node.width, node.height)

    floor.bb.node = floor
    floor.bb:move(0, offset)

    if floor.angled then
        local block = {}
        block.width = 24
        block.height = 24
        block.y = node.y + offset - 12

        block.x = node.x + node.height - offset - 24
        floor.rightBlock = Block.new(block, collider)

        block.x = node.x + node.width - node.height + offset
        floor.leftBlock = Block.new(block, collider)
    end

    collider:setPassive(floor.bb)
    return floor
end

function Floorspace:update(dt, player)
    if player.jumping or player.freeze or player.stopped then
        return
    end

    local _, wy1, _, _  = self.bb:bbox()

    local moveDown = controls.isDown( 'DOWN' )
    local moveUp = controls.isDown( 'UP' )

    if moveDown and wy1 <= self.maxy and not player.blocked_down then
        self.bb:move(0, dt * 100)

        if self.angled then
            self.rightBlock.bb:move(dt * -100, dt * 100)
            self.leftBlock.bb:move(dt * 100, dt * 100)
        end
    elseif moveUp and wy1 >= self.miny and not player.blocked_up then
        self.bb:move(0, dt * -100)

        if self.angled then
            self.rightBlock.bb:move(dt * 100, dt * -100)
            self.leftBlock.bb:move(dt * -100, dt * -100)
        end
    end
end

function Floorspace:collide(node, dt, mtv_x, mtv_y)
    if not node.isPlayer then return end
    local player = node
    
    local _, wy1, _, wy2  = self.bb:bbox()
    local _, py1, _, py2 = player.top_bb:bbox()

    if player.velocity.y >= 0 then --and math.abs(wy1 - py2) <= distance then
        player.velocity.y = 0
        player.position.y = wy1 - player.height + 2 -- fudge factor
        player:moveBoundingBox()

        player:restore_solid_ground()
        player.jumping = false
        player.rebounding = false
    end
end

return Floorspace
