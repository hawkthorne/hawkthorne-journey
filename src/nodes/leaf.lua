-----------------------------------------------
-- leaf.lua
-- Represents a leaf when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local controls = require 'controls'

local Leaf = {}
Leaf.__index = Leaf
Leaf.leaf = true

local LeafImage = love.graphics.newImage('images/leaf.png')
local LeafItem = require('items/leafItem')

---
-- Creates a new leaf object
-- @return the leaf object created
function Leaf.new(node, collider)
    local leaf = {}
    setmetatable(leaf, Leaf)
    leaf.image = LeafImage
    leaf.foreground = node.properties.foreground
    leaf.collider = collider
    leaf.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    leaf.bb.node = leaf
    collider:setPassive(leaf.bb)

    leaf.node = node
    
    leaf.position = {x = node.x, y = node.y}
    leaf.width = node.width
    leaf.height = node.height

    leaf.touchedPlayer = nil
    leaf.exists = true

    return leaf
end

---
-- Draws the leaf to the screen
-- @return nil
function Leaf:draw()
    if not self.exists then
        return
    end
    love.graphics.drawq(self.image, love.graphics.newQuad(0,0, self.width,self.height,self.width,self.height), self.position.x, self.position.y)
end

---
-- Called when the leaf begins colliding with another node
-- @return nil
function Leaf:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the leaf finishes colliding with another node
-- @return nil
function Leaf:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the leaf and allows the player to pick it up.
function Leaf:update()
    if not self.exists then
        return
    end
    if controls.isDown( 'UP' ) and self.touchedPlayer then
        local item = LeafItem.new()
        if self.touchedPlayer.inventory:addItem(item) then
            self.exists = false
            self.collider:remove(self.bb)
        end
    end
end

return Leaf
