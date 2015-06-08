-----------------------------------------------
-- armor.lua
-- Represents armor when it is in the world
-----------------------------------------------

local game = require 'game'
local collision  = require 'hawk/collision'
local Item = require 'items/item'
local utils = require 'utils'

local Armor = {}
Armor.__index = Armor
Armor.isArmor = true

---
-- Creates a new armor object
-- @return the armor object created
function Armor.new(node, collider)
  local armor = {}
  setmetatable(armor, Armor)
  armor.name = node.name
  armor.type = 'armor'
  
  local props = utils.require( 'nodes/armor/' .. armor.name )
  
  armor.image = love.graphics.newImage('images/armors/'..node.name..'.png')
  armor.image_q = love.graphics.newQuad( 0, 0, props.width, props.height, armor.image:getWidth(),armor.image:getHeight() )
  armor.foreground = node.properties.foreground
  armor.collider = collider
  armor.bb = collider:addRectangle(node.x, node.y, props.width, props.height)
  armor.bb.node = armor
  collider:setSolid(armor.bb)
  collider:setPassive(armor.bb)

  armor.position = {x = node.x, y = node.y}
  armor.velocity = {x = 0, y = 0}
  armor.width = props.width
  armor.height = props.height

  armor.touchedPlayer = nil
  armor.exists = true
  armor.dropping = false

  return armor
end

---
-- Draws the armor to the screen
-- @return nil
function Armor:draw()
  if not self.exists then
    return
  end
  love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Armor:keypressed( button, player )
  if button ~= 'INTERACT' then return end

  local itemNode = utils.require( 'items/armor/' .. self.name )
  itemNode.type = 'armor'
  local item = Item.new(itemNode, self.quantity)
  local callback = function()
    self.exists = false
    self.containerLevel:saveRemovedNode(self)
    self.containerLevel:removeNode(self)
    self.collider:remove(self.bb)
  end
  player.inventory:addItem(item, false, callback)
end

---
-- Called when the armor begins colliding with another node
-- @return nil
function Armor:collide(node, dt, mtv_x, mtv_y)
  if node and node.character then
    self.touchedPlayer = node
  end
end

---
-- Called when the armor finishes colliding with another node
-- @return nil
function Armor:collide_end(node, dt)
  if node and node.character then
    self.touchedPlayer = nil
  end
end

---
-- Updates the armor and allows the player to pick it up.
function Armor:update(dt, player, map)
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
    
    self.bb:moveTo(self.position.x + self.width / 2, self.position.y + self.height / 2)
  end

  -- Item has finished dropping in the level
  if not self.dropping and self.dropped and not self.saved then
    self.containerLevel:saveAddedNode(self)
    self.saved = true
  end
end

function Armor:drop(player)
  if player.footprint then
    self:floorspace_drop(player)
    return
  end

  self.dropping = true
  self.dropped = true
end

function Armor:floorspace_drop(player)
  self.dropping = false
  self.position.y = player.footprint.y - self.height
  self.bb:moveTo(self.position.x + self.width / 2, self.position.y + self.height / 2)

  self.containerLevel:saveAddedNode(self)
end

function Armor:floor_pushback()
  if not self.exists or not self.dropping then return end
  
  self.dropping = false
  self.velocity.y = 0
  self.collider:setPassive(self.bb)
end

return Armor
