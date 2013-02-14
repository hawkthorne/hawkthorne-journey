local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local game = require 'game'

local Token = {}
Token.__index = Token
 
function Token.new( type, x, y, collider, value )
    local token = {}
    setmetatable(token, Token)

    token.item = require ( 'tokens/' .. type )

    token.height = token.item.height
    token.width = token.item.width

    token.collider = collider

    token.foreground = true

    token.sprite = love.graphics.newImage('images/tokens/' .. type .. '.png')
    token.g = anim8.newGrid( token.width, token.height, token.sprite:getWidth(), token.sprite:getHeight())

    token.position = {
        x = x + token.width / 2,
        y = y - token.height - 5
    }
    token.velocity = {
        x = math.rsign() * ( (math.random(100) + 10 ) * 3),
        y = -375
    }

    token.life = 5
    token.blinklife = 2
    token.speed = 300
    token.active = true
    token.delay = 0.1

    token.bb = collider:addRectangle( token.position.x, token.position.y, token.width, token.height )
    token.bb.node = token

    token.tokenAnimate = anim8.newAnimation( 'loop', token.g( token.item.frames ), token.item.speed )

    -- collider:setPassive(token.bb)

    return token
end

function Token:update(dt, player)
    if self.active then
        self.delay = self.delay - dt
        if self.delay > 0 then return end
        self.life = self.life - dt
        if self.life < 0 then
            self.active = false
            self.collider:remove(self.bb)
        end
            
        self.tokenAnimate:update(dt)

        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + ( 0.1 * game.step ) * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - ( 0.1 * game.step ) * dt, 0)
        end

        self.velocity.y = self.velocity.y + game.gravity * dt

        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt
        
        self:moveBoundingBox()
    end
end

function Token:moveBoundingBox()
    self.bb:moveTo(self.position.x + self.height / 2, self.position.y + self.height / 2)
end

function Token:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        local player = node
        if self.active then
            sound.playSfx('pickup')
            self.active = false
            self.item.onPickup( player, self.item.value )
            self.collider:remove(self.bb)
        end
    end
end

function Token:draw()
    if self.active and self.delay < 0 then
        if self.life <= self.blinklife then
            if math.floor( self.life * 10 ) % 2 == 1 then
                self.tokenAnimate:draw(self.sprite, self.position.x, self.position.y)
            end
        else
            self.tokenAnimate:draw(self.sprite, self.position.x, self.position.y)
        end
    end
end

function Token:floor_pushback(node, new_y)
    self.position.y = new_y
    self.velocity.y = 0
    self:moveBoundingBox()
end

function Token:wall_pushback(node, new_x)
    self.position.x = new_x
    self.velocity.x = 0
    self:moveBoundingBox()
end

return Token
