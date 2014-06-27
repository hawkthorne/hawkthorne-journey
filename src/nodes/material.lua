-----------------------------------------------
-- material.lua
-- Represents a material when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local game = require 'game'
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
    if player.inventory:addItem(item) then
        self.exists = false
        self.containerLevel:removeNode(self)
        self.collider:remove(self.bb)
        -- Key has been handled, halt further processing
        return true
    end
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
function Material:update(dt)
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
end

function Material:floor_pushback(node, new_y)
    if not self.exists or not self.dropping then return end
    
    self.dropping = false
    self.position.y = new_y
    self.velocity.y = 0
    self.collider:setPassive(self.bb)
end

return Material
