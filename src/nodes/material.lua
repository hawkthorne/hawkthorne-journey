-----------------------------------------------
-- material.lua
-- Represents a material when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local game = require 'game'
local collision  = require 'hawk/collision'
local Item = require 'items/item'
local utils = require 'utils'

local Material = {}
Material.__index = Material
Material.isMaterial = true

---
-- Creates a new material object
-- @return the material object created
function Material.new(node, collider)
    local material = {}
    setmetatable(material, Material)
    material.name = node.name
    material.type = 'material'
    material.image = love.graphics.newImage('images/materials/'..node.name..'.png')
    material.image_q = love.graphics.newQuad( 0, 0, 24, 24, material.image:getWidth(),material.image:getHeight() )
    material.foreground = node.properties.foreground
    material.collider = collider
    material.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    material.bb.node = material
    collider:setSolid(material.bb)
    collider:setPassive(material.bb)

    material.position = {x = node.x, y = node.y}
    material.velocity = {x = 0, y = 0}
    material.width = node.width
    material.height = node.height
    material.bb_offset_x = (24 - node.width) / 2 -- positions bb for materials smaller than 24px

    material.touchedPlayer = nil
    material.exists = true
    material.dropping = false

    return material
end

---
-- Draws the material to the screen
-- @return nil
function Material:draw()
    if not self.exists then
        return
    end
    love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Material:keypressed( button, player )
    if button ~= 'INTERACT' then return end

    local itemNode = utils.require( 'items/materials/' .. self.name )
    itemNode.type = 'material'
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
-- Called when the material begins colliding with another node
-- @return nil
function Material:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the material finishes colliding with another node
-- @return nil
function Material:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the material and allows the player to pick it up.
function Material:update(dt, player, map)
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
end

function Material:drop(player)
    if player.footprint then
        self:floorspace_drop(player)
        return
    end
    
    self.dropping = true
end

function Material:floorspace_drop(player)
    self.dropping = false
    self.position.y = player.footprint.y - self.height

    self.containerLevel:saveAddedNode(self)
end

function Material:floor_pushback()
    if not self.exists or not self.dropping then return end
    
    self.dropping = false
    self.velocity.y = 0
    self.collider:setPassive(self.bb)

    self.containerLevel:saveAddedNode(self)
end

return Material
