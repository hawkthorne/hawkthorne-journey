local Platform = {}
Platform.__index = Platform
Platform.isPlatform = true

function Platform.new(node, collider)
  local platform = {}
  setmetatable(platform, Platform)

  --If the node is a polyline, we need to draw a polygon rather than rectangle
  if node.polyline or node.polygon then
    local polygon = node.polyline or node.polygon
    local vertices = {}

    for i, point in ipairs(polygon) do
      table.insert(vertices, node.x + point.x)
      table.insert(vertices, node.y + point.y)
    end

    platform.bb = collider:addPolygon(unpack(vertices))
    platform.bb.polyline = polygon
  else
    platform.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    platform.bb.polyline = nil
  end

  platform.node = node
  
  platform.drop = node.properties.drop ~= 'false'

  platform.bb.node = platform
  collider:setPassive(platform.bb)
  platform.collider = collider

  return platform
end

function Platform:collide( node, dt, mtv_x, mtv_y, bb )
  bb = bb or node.bb

  if not node.floor_pushback then return end

  if node.isPlayer then
    --ignore head vs. platform collisions
    -- ignores node that isn't the one currently standing on
    if bb == node.top_bb or (node.velocity.y == 0 and mtv_x ~= 0 ) or mtv_y >= 0 then
      return
    end

    self.player_touched = true
    
    if node.platform_dropping == true and self.drop then
      node.platform_dropping = self
    end

    if node.platform_dropping == self then
      return
    end
  end
  if node.bb then
    node.top_bb = node.bb
    node.bottom_bb = node.bb
  end

  if not node.top_bb or not node.bottom_bb then return end

  local _, wy1, _, wy2  = self.bb:bbox()
  local px1, py1, _, _ = node.top_bb:bbox()
  local _, _, px2, py2 = node.bottom_bb:bbox()
  local distance = math.abs(node.velocity.y * dt) + 2.10

  if self.bb.polyline and node.velocity.y >= 0 then
    -- If the player is close enough to the tip bring the player to the tip
    if math.abs(wy1 - py2) < 2 then
      node:floor_pushback(self, wy1 - node.height)

    -- Prevent the player from being treadmilled through an object
    elseif self.bb:contains(px2,py2) or self.bb:contains(px1,py2) then

      -- Use the MTV to keep players feet on the ground
      node:floor_pushback(self, (py2 - node.height) + mtv_y)

    end

  elseif node.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then
    node:floor_pushback(self, wy1 - node.height)
  elseif node.velocity.y > 0 and mtv_y < 0 and mtv_y > -5 then
    node:floor_pushback(self, wy1 - node.height)
  end
end

function Platform:collide_end(node)
  if node.isPlayer then
    self.player_touched = false
  end
end

return Platform
