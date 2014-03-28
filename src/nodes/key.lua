-----------------------------------------------
-- key.lua
-- Represents a key when it is in the world
-----------------------------------------------

local Item = require 'items/item'
local Prompt = require 'prompt'
local utils = require 'utils'

local Key = {}
Key.__index = Key

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
    key.info = node.properties.info
    
    if collider then
        key.collider = collider
        key.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
        key.bb.node = key
        collider:setPassive(key.bb)
    end

    key.position = {x = node.x, y = node.y}
    key.width = node.width
    key.height = node.height

    key.touchedPlayer = nil

    return key
end

---
-- Draws the key to the screen
-- @return nil
function Key:draw()
    love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end

function Key:keypressed( button, player )

    if button ~= 'INTERACT' then return end

    local itemNode = utils.require ('items/keys/'..self.name)
    local item = Item.new(itemNode, self.quantity)

    if player.inventory:addItem(item) then
        self.containerLevel:removeNode(self)
    end

    local message = self.info or {'You found the "'..item.description..'" key!'}
    self.touchedPlayer.character.state = 'acquire'

    local callback = function(result)
        self.prompt = nil
        player.freeze = false
        player.invulnerable = false
    end
    local options = {'Exit'}
    player.freeze = true
    player.invulnerable = true
    self.position = { x = player.position.x +10 ,y = player.position.y - 10}
    self.prompt = Prompt.new(message, callback, options, self)
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
    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2,
                 self.position.y + (y2-y1)/2)

end

return Key