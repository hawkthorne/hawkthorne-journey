-----------------------------------------------
-- flying_knife.lua
-- Represents a knife that a player has thrown
-- Created by HazardousPeach
-----------------------------------------------

local Knife = {}
Knife.__index = Knife
Knife.knife = true

---
-- Creates a new flying knife object
-- @return the flying knife object created
function Knife.new(node, collider)
    local knife = {}
    setmetatable(knife, Knife)
    knife.image = love.graphics.newImage('images/weapons/throwingknife.png')
    knife.image_q = love.graphics.newQuad( 0, 0, 24, 24, knife.image:getWidth(), knife.image:getHeight() )
    knife.foreground = node.properties.foreground
    knife.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    knife.bb.node = knife
    knife.collider = collider

    knife.position = {x = node.x, y = node.y}
    knife.start_x = node.x
    knife.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    knife.width = node.width
    knife.height = node.height
    knife.damage = 2
    knife.dead = false
    knife.isRangeWeapon = true

    return knife
end

---
-- Draws the knife to the screen
-- @return nil
function Knife:draw()
    if self.dead then return end
    local scalex = 1
    if ((self.velocity.x + 0)< 0) then
        scalex = -1
    end
    love.graphics.drawq(self.image, self.image_q, self.position.x, self.position.y, 0, scalex, 1)
end

---
-- Called when the knife begins colliding with another node
-- @return nil
function Knife:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.hurt then
        node:hurt(self.damage)
        self.dead = true
        self.collider:remove(self.bb)
    end
    if node.isSolid then
        self.dead = true
        self.collider:remove(self.bb)
    end
end

---
-- Called when the knife finishes colliding with another node
-- @return nil
function Knife:collide_end(node, dt)
end

---
-- Updates the knife and moves it around.
function Knife:update()
    if self.dead then return end
    self.position = {x=self.position.x + self.velocity.x, y=self.position.y + self.velocity.y}
    if math.abs(self.start_x - self.position.x) > 600 then
        self.dead = true
        self.collider:remove(self.bb)
        return
    end
    self.bb:moveTo(self.position.x, self.position.y)
end

return Knife