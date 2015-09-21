-----------------------------------------------
-- detail.lua
-- Represents a detail when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local game = require 'game'
local collision  = require 'hawk/collision'
local Item = require 'items/item'
local utils = require 'utils'

local Detail = {}
Detail.__index = Detail
Detail.isDetail = true

---
-- Creates a new detail object
-- @return the detail object created
function Detail.new(node, collider)
  local detail = {}
  setmetatable(detail, Detail)
  detail.name = node.name
  detail.type = 'detail'
  local category = node.properties.category or 'recipe'
  detail.image = love.graphics.newImage('images/details/'..category..'.png') -- category can be quest or recipe
  detail.image_q = love.graphics.newQuad( 0, 0, 24, 24, detail.image:getDimensions() )
  detail.foreground = node.properties.foreground
  detail.collider = collider
  detail.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  detail.bb.node = detail
  collider:setSolid(detail.bb)
  collider:setPassive(detail.bb)

  detail.position = {x = node.x, y = node.y}
  detail.velocity = {x = 0, y = 0}
  detail.width = node.width
  detail.height = node.height
  detail.bb_offset_x = (24 - node.width) / 2 -- positions bb for details smaller than 24px

  detail.touchedPlayer = nil
  detail.exists = true
  detail.dropping = false

  return detail
end

---
-- Draws the detail to the screen
-- @return nil
function Detail:draw()
  if not self.exists then
    return
  end
  love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Detail:keypressed( button, player )
  if button ~= 'INTERACT' then return end

  local itemNode = utils.require( 'items/details/' .. self.name )
  itemNode.type = 'detail'
  local item = Item.new(itemNode, self.quantity)
  local callback = function()
    self.exists = false
    self.containerLevel:saveRemovedNode(self)
    self.containerLevel:removeNode(self)
    self.collider:remove(self.bb)
  end
  player.inventory:addItem(item, true, callback)
end

---
-- Called when the detail begins colliding with another node
-- @return nil
function Detail:collide(node, dt, mtv_x, mtv_y)
  if node and node.character then
    self.touchedPlayer = node
  end
end

---
-- Called when the detail finishes colliding with another node
-- @return nil
function Detail:collide_end(node, dt)
  if node and node.character then
    self.touchedPlayer = nil
  end
end

---
-- Updates the detail and allows the player to pick it up.
function Detail:update(dt, player, map)
  if not self.exists then
    return
  end
  if self.dropping then  
    local nx, ny = collision.move(map, self, self.position.x, self.position.y,
                                  self.width, self.height, 
                                  self.velocity.x * dt, self.velocity.y * dt)
    self.position.x = nx
    self.position.y = ny

    -- X velocity won't need to change
    self.velocity.y = self.velocity.y + game.gravity*dt
    
    self.bb:moveTo(self.position.x + self.width / 2 + self.bb_offset_x, self.position.y + self.height / 2)
  end

  -- Item has finished dropping in the level
  if not self.dropping and self.dropped and not self.saved then
    self.containerLevel:saveAddedNode(self)
    self.saved = true
  end
end

function Detail:drop(player)
  if player.footprint then
    self:floorspace_drop(player)
    return
  end

  self.dropping = true
  self.dropped = true
end

function Detail:floorspace_drop(player)
  self.dropping = false
  self.position.y = player.footprint.y - self.height
  self.bb:moveTo(self.position.x + self.width / 2 + self.bb_offset_x, self.position.y + self.height / 2)

  self.containerLevel:saveAddedNode(self)
end

function Detail:floor_pushback()
  if not self.exists or not self.dropping then return end
  
  self.dropping = false
  self.velocity.y = 0
  self.collider:setPassive(self.bb)
end

return Detail
