-----------------------------------------------
-- stick.lua
-- Represents a stick when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local controls = require 'controls'

local Stick = {}
Stick.__index = Stick
Stick.stick = true

local StickImage = love.graphics.newImage('images/stick.png')
local StickItem = require('items/stickItem')

---
-- Creates a new stick object
-- @return the stick object created
function Stick.new(node, collider)
    local stick = {}
    setmetatable(stick, Stick)
    stick.image = StickImage
    stick.foreground = node.properties.foreground
    stick.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    stick.bb.node = stick
    stick.collider = collider

    stick.position = {x = node.x, y = node.y}
    stick.width = node.width
    stick.height = node.height

    stick.touchedPlayer = nil
    stick.exists = true

    return stick
end

---
-- Draws the stick to the screen
-- @return nil
function Stick:draw()
    if not self.exists then
        return
    end
    love.graphics.drawq(self.image, love.graphics.newQuad(0,0, self.width,self.height,self.width,self.height), self.position.x, self.position.y)
end

---
-- Called when the stick begins colliding with another node
-- @return nil
function Stick:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the stick finishes colliding with another node
-- @return nil
function Stick:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the stick and allows the player to pick it up.
function Stick:update()
    if not self.exists then
        return
    end
    if controls.isDown( 'UP' ) and self.touchedPlayer then
        local item = StickItem.new()
        if self.touchedPlayer.inventory:addItem(item) then
            self.exists = false
        end
    end
end

return Stick
