-----------------------------------------------
-- rock.lua
-- Represents a rock when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local controls = require 'controls'

local Rock = {}
Rock.__index = Rock
Rock.rock = true

local RockImage = love.graphics.newImage('images/rock.png')
local RockItem = require('items/rockItem')

---
-- Creates a new rock object
-- @return the rock object created
function Rock.new(node, collider)
    local rock = {}
    setmetatable(rock, Rock)
    rock.image = RockImage
    rock.foreground = node.properties.foreground
    rock.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    rock.bb.node = rock
    rock.collider = collider

    rock.position = {x = node.x, y = node.y}
    rock.width = node.width
    rock.height = node.height

    rock.touchedPlayer = nil
    rock.exists = true

    return rock
end

---
-- Draws the rock to the screen
-- @return nil
function Rock:draw()
    if not self.exists then
        return
    end
    love.graphics.drawq(self.image, love.graphics.newQuad(0,0, self.width,self.height,self.width,self.height), self.position.x, self.position.y)
end

---
-- Called when the rock begins colliding with another node
-- @return nil
function Rock:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the rock finishes colliding with another node
-- @return nil
function Rock:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the rock and allows the player to pick it up.
function Rock:update()
    if not self.exists then
        return
    end
    if controls:isDown( 'UP' ) and self.touchedPlayer then
        local item = RockItem.new()
        if self.touchedPlayer.inventory:addItem(item) then
            self.exists = false
        end
    end
end

return Rock