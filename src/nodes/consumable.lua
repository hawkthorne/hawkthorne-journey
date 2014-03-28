-----------------------------------------------
-- consumable.lua
-- Represents a consumable when it is in the world
-- Created by Nicko21
-----------------------------------------------

local game = require 'game'
local Item = require 'items/item'
local utils = require 'utils'

local Consumable = {}
Consumable.__index = Consumable

---
-- Creates a new consumable object
-- @return the consumable object created
function Consumable.new(node, collider)
    local consumable = {}
    setmetatable(consumable, Consumable)
    consumable.name = node.name
    consumable.type = 'consumable'

    if not love.filesystem.exists('images/consumables/'..node.name..'.png') then
      return nil
    end

    consumable.image = love.graphics.newImage('images/consumables/'..node.name..'.png')
    consumable.image_q = love.graphics.newQuad( 0, 0, 24, 24, consumable.image:getWidth(),consumable.image:getHeight() )
    consumable.foreground = node.properties.foreground
    consumable.collider = collider
    consumable.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    consumable.bb.node = consumable
    collider:setSolid(consumable.bb)

    consumable.position = {x = node.x, y = node.y}
    consumable.velocity = {x = 0, y = 0}
    consumable.width = node.width
    consumable.height = node.height

    consumable.touchedPlayer = nil
    consumable.exists = true
    consumable.dropping = false

    return consumable
end

---
-- Draws the consumable to the screen
-- @return nil
function Consumable:draw()
    if not self.exists then
        return
    end
    love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Consumable:keypressed( button, player )
    if button ~= 'INTERACT' then return end

    local itemNode = utils.require( 'items/consumables/' .. self.name )
    itemNode.type = 'consumable'
    local item = Item.new(itemNode, self.quantity)
    if player.inventory:addItem(item) then
        self.exists = false
        self.containerLevel:removeNode(self)
        self.collider:remove(self.bb)
        -- Key has been handled, halt further processing
        return true
    end
end

---
-- Called when the consumable begins colliding with another node
-- @return nil
function Consumable:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the consumable finishes colliding with another node
-- @return nil
function Consumable:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the consumable and allows the player to pick it up.
function Consumable:update(dt)
    if not self.exists then
        return
    end
    if self.dropping then
        -- gravity
        self.position = {x = self.position.x + self.velocity.x*dt,
                         y = self.position.y + self.velocity.y*dt
                        }
        -- X velocity won't need to change
        self.velocity.y = self.velocity.y + game.gravity*dt
        -- 12 is half the size
        self.bb:moveTo(self.position.x + 12, self.position.y + 12)
    end
end

function Consumable:drop(player)
    if player.footprint then
        self:floorspace_drop(player)
        return
    end
    
    self.dropping = true
end

function Consumable:floorspace_drop(player)
    self.dropping = false
    self.position.y = player.footprint.y - self.height
end

function Consumable:floor_pushback(node, new_y)
    if not self.exists or not self.dropping then return end
    
    self.dropping = false
    self.position.y = new_y
    self.velocity.y = 0
    self.collider:setPassive(self.bb)
end

return Consumable
