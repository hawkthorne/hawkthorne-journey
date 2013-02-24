-----------------------------------------------
-- key.lua
-- Represents a key when it is in the world
-----------------------------------------------

local controls = require 'controls'
local Item = require 'items/item'
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'

local Key = {}
Key.__index = Key
Key.isKey = true

---
-- Creates a new key object
-- @return the key object created
function Key.new(node, collider)
    local key = {}
    setmetatable(key, Key)
    key.name = node.name
    key.image = love.graphics.newImage('images/keys/'..node.name..'.png')
    key.image_q = love.graphics.newQuad( 0, 0, 24, 24, key.image:getWidth(),key.image:getHeight() )
    key.foreground = node.properties.foreground
    key.collider = collider
    key.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    key.bb.node = key
    collider:setPassive(key.bb)

    key.position = {x = node.x, y = node.y}
    key.width = node.width
    key.height = node.height

    key.touchedPlayer = nil
    key.exists = true

    return key
end

---
-- Draws the key to the screen
-- @return nil
function Key:draw()
    if self.prompt then
        self.prompt:draw(self.position.x + 20, self.position.y - 35)
    end
    if not self.exists then
        return
    end
    love.graphics.drawq(self.image, self.image_q, self.position.x, self.position.y)
end

--optional function that isn't used
--we use a timer to deactivate the prompt
function Key:keypressed( button, player )
    if self.prompt then
        return self.prompt:keypressed( button )
    end
end

---
-- Called when the key begins colliding with another node
-- @return nil
function Key:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        self.touchedPlayer = node
    end
end

---
-- Called when the key finishes colliding with another node
-- @return nil
function Key:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
end

---
-- Updates the key and allows the player to pick it up.
function Key:update(dt)
    if self.prompt then self.prompt:update(dt) end
    if not self.exists then
        return
    end
    if controls.isDown( 'UP' ) and self.touchedPlayer and not self.touchedPlayer.controlState:is('ignoreMovement') then
        local itemNode = {type = 'key',name = self.name}
        local item = Item.new(itemNode)
        local message = {'You found a "'..self.name..'" key!'}
        self.touchedPlayer.character.state = 'jump'
        
        local callback = function(result)
            self.prompt = nil
            self.touchedPlayer.freeze = false
            self.touchedPlayer.invulnerable = false
            if self.touchedPlayer.inventory:addItem(item) then
                self.exists = false
                self.collider:remove(self.bb)
            end
        end
        local options = {'Exit'}
        self.touchedPlayer.freeze = true
        self.touchedPlayer.invulnerable = true
        self.prompt = Prompt.new(message, callback, options)
    end
end

return Key
