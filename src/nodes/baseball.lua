local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local window = require 'window'
local game = require 'game'

local Baseball = {}
Baseball.__index = Baseball
Baseball.baseball = true

local BaseballImage = love.graphics.newImage('images/baseball.png')
local g = anim8.newGrid(9, 9, BaseballImage:getWidth(), BaseballImage:getHeight())

function Baseball.new(node, collider, map)
    local baseball = {}
    setmetatable(baseball, Baseball)
    baseball.image = BaseballImage
    baseball.quad = love.graphics.newQuad( 0, 0, 9, 9, 18, 9 )
    baseball.foreground = node.properties.foreground
    baseball.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    baseball.bb.node = baseball
    baseball.collider = collider
    baseball.spinning = anim8.newAnimation('loop', g('1-2,1'), .10)

    baseball.position = { x = node.x, y = node.y }
    baseball.velocity = { x = -230, y = -200 }
    baseball.friction = 0.01 * game.step; -- A baseball is a low-friction object.

    baseball.floor = map.objectgroups.floor.objects[1].y - node.height + 2
    baseball.thrown = true
    baseball.held = false
    baseball.rebounded = false

    baseball.width = node.width
    baseball.height = node.height
    
    return baseball
end

function Baseball:draw()
    if self.thrown then
        self.spinning:draw(self.image, self.position.x, self.position.y)
    else
        love.graphics.drawq(self.image, self.quad, self.position.x, self.position.y)
    end
end

function Baseball:collide(node, dt, mtv_x, mtv_y)
    if node and node.character then
        node:registerHoldable(self)
    end
end

function Baseball:collide_end(node, dt)
    if node and node.character then
        node:cancelHoldable(self)
    end
end

function Baseball:update(dt, player)
    if self.held and player.currently_held == self then
        self.position.x = math.floor(player.position.x) + player.offset_hand_right[1] + (self.width / 2) + 15
        self.position.y = math.floor(player.position.y) + player.offset_hand_right[2] - self.height + 2
        if player.offset_hand_right[1] == 0 then
            print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
        end
        self:moveBoundingBox()
    end

    if self.thrown then

        self.spinning:update(dt)

        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + self.friction * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - self.friction * dt, 0)
        end

        self.velocity.y = self.velocity.y + game.gravity * dt

        if self.velocity.y > game.max_y then
            self.velocity.y = game.max_y
        end
    
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt

        if self.position.x < 0 then
            self.position.x = 0
            self.rebounded = false
            self.velocity.x = -self.velocity.x
        end

        if self.position.x + self.width > window.width then
            self.position.x = window.width - self.width
            self.rebounded = false
            self.velocity.x = -self.velocity.x
        end

        if self.thrown and self.position.y >= self.floor then
            self.rebounded = false
            if self.velocity.y < 25 then
                --stop bounce
                self.velocity.y = 0
                self.position.y = self.floor
                self.thrown = false
            else
                --bounce 
                self.position.y = self.floor
                self.velocity.y = -.8 * math.abs( self.velocity.y )
            end
        end
    
    end
    
    self:moveBoundingBox()
    
end

function Baseball:moveBoundingBox()
    Helper.moveBoundingBox(self)
end

function Baseball:pickup(player)
    self.held = true
    self.thrown = false
    self.velocity.y = 0
    self.velocity.x = 0
end

function Baseball:throw(player)
    self.held = false
    self.thrown = true
    self.velocity.x = ( ( ( player.direction == "left" ) and -1 or 1 ) * 500 ) + player.velocity.x
    self.velocity.y = -800
end

function Baseball:throw_vertical(player)
    self.held = false
    self.thrown = true
    self.velocity.x = player.velocity.x
    self.velocity.y = -800
end

function Baseball:drop(player)
    self.held = false
    self.thrown = true
    self.velocity.x = ( ( ( player.direction == "left" ) and -1 or 1 ) * 50 ) + player.velocity.x
    self.velocity.y = 0
end

---
-- Gets the current acceleration speed
-- @return Number the acceleration to apply
function Baseball:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

---
-- Gets the current deceleration speed
-- @return Number the deceleration to apply
function Baseball:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end

function Baseball:rebound( x_change, y_change )
    if not self.rebounded then
        if x_change then
            self.velocity.x = -( self.velocity.x / 2 )
        end
        if y_change then
            self.velocity.y = -self.velocity.y
        end
        self.rebounded = true
    end
end


return Baseball

