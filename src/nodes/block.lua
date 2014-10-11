local game = require 'game'
local Block = {}
Block.__index = Block

function Block.new(node, collider, ice)
  local block = {}
  setmetatable(block, Block)
  block.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  block.bb.node = block
  block.node = node
  collider:setPassive(block.bb)
  block.isSolid = true

  block.ice = (ice and true) or false

  return block
end

function Block:collide( node, dt, mtv_x, mtv_y, bb)
  bb = bb or node.bb
  if not (node.floor_pushback or node.wall_pushback) then return end

  node.bottom_bb = node.bottom_bb or node.bb
  node.top_bb = node.top_bb or node.bb

  if not node.top_bb or not node.bottom_bb then return end

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

  if mtv_y < 0 and (not node.isPlayer or bb == node.bottom_bb) and node.velocity.y >= 0 then
    -- standing on top
    node:floor_pushback(self, self.node.y - node.height)

    node.on_ice = self.ice
    if self.ice and math.abs(node.velocity.x) < 500 then
      if node.velocity.x < 0 then
        node.velocity.x = math.min(node.velocity.x - game.friction * dt / 6, 0)
      elseif node.velocity.x > 0 then
        node.velocity.x = math.max(node.velocity.x + game.friction * dt / 6, 0)
      end
    end
  end

end

function Block:collide_end( node ,dt )
end

return Block
