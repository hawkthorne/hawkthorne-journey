-----------------------------------------------
-- armour.lua
-- Represents armour when it is in the world
-----------------------------------------------

local game = require 'game'
local collision  = require 'hawk/collision'
local Item = require 'items/item'
local utils = require 'utils'

local Armour = {}
Armour.__index = Armour
Armour.isArmour = true

---
-- Creates a new armour object
-- @return the armour object created
function Armour.new(node, collider)
  local armour = {}
  setmetatable(armour, Armour)
  armour.name = node.name
  armour.type = 'armour'
  
  local props = utils.require( 'nodes/armour/' .. armour.name )
  
  armour.image = love.graphics.newImage('images/armours/'..node.name..'.png')
  armour.image_q = love.graphics.newQuad( 0, 0, props.width, props.height, armour.image:getWidth(),armour.image:getHeight() )
  armour.foreground = node.properties.foreground
  armour.collider = collider
  armour.bb = collider:addRectangle(node.x, node.y, props.width, props.height)
  armour.bb.node = armour
  collider:setSolid(armour.bb)
  collider:setPassive(armour.bb)

  armour.position = {x = node.x, y = node.y}
  armour.velocity = {x = 0, y = 0}
  armour.width = props.width
  armour.height = props.height

  armour.touchedPlayer = nil
  armour.exists = true
  armour.dropping = false

  return armour
end

---
-- Draws the armour to the screen
-- @return nil
function Armour:draw()
  if not self.exists then
    return
  end
  love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Armour:keypressed( button, player )
  if button ~= 'INTERACT' then return end

  local itemNode = utils.require( 'items/armour/' .. self.name )
  itemNode.type = 'armour'
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
-- Called when the armour begins colliding with another node
-- @return nil
function Armour:collide(node, dt, mtv_x, mtv_y)
  if node and node.character then
    self.touchedPlayer = node
  end
end

---
-- Called when the armour finishes colliding with another node
-- @return nil
function Armour:collide_end(node, dt)
  if node and node.character then
    self.touchedPlayer = nil
  end
end

---
-- Updates the armour and allows the player to pick it up.
function Armour:update(dt, player, map)
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

function Armour:drop(player)
  if player.footprint then
    self:floorspace_drop(player)
    return
  end

  self.dropping = true
  self.dropped = true
end

function Armour:floorspace_drop(player)
  self.dropping = false
  self.position.y = player.footprint.y - self.height
  self.bb:moveTo(self.position.x + self.width / 2, self.position.y + self.height / 2)

  self.containerLevel:saveAddedNode(self)
end

function Armour:floor_pushback()
  if not self.exists or not self.dropping then return end
  
  self.dropping = false
  self.velocity.y = 0
  self.collider:setPassive(self.bb)
end

return Armour
