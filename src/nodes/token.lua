local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local game = require 'game'

local Token = {}
Token.__index = Token
 
function Token.new( type, x, floory, collider, value )
    local token = {}
    setmetatable(token, Token)

    token.item = require ( 'tokens/' .. type )

    token.collider = collider

    token.foreground = true

    token.sprite = love.graphics.newImage('images/tokens/' .. type .. '.png')
    token.g = anim8.newGrid( token.item.width, token.item.height, token.sprite:getWidth(), token.sprite:getHeight())

    token.position = { x=x, y=floory }
    token.velocity = { x=(math.random(30)-15)*30, y=-175 }

    token.life = 5
    token.blinklife = 2
    token.speed = 300
    token.active = true

    token.floory = floory

    token.bb = collider:addRectangle( token.position.x, token.position.y, token.item.width, token.item.height )
    token.bb.node = token

    token.tokenAnimate = anim8.newAnimation( 'loop', token.g( token.item.frames ), token.item.speed )

    collider:setPassive(token.bb)

    return token
end

function Token:update(dt, player)
    if self.active then
        self.life = self.life - dt
        if self.life < 0 then
            self.active = false
        end
            
        self.tokenAnimate:update(dt)

        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.airaccel * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.airaccel * dt, 0)
        end

        self.velocity.y = self.velocity.y + game.gravity / 2 * dt

        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt

        if self.position.y + self.item.height > self.floory then
            self.position.y = self.floory - self.item.height
        end

        self.bb:moveTo(self.position.x + 4, self.position.y + 4)
    end
end

function Token:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        local player = node
        if self.active then
            sound.playSfx('pickup')
            self.active = false
            self.item.onPickup( player, self.item.value )
            self.collider:setGhost(self.bb)
        end
    end
end

function Token:draw()
    if self.active then
        if self.life <= self.blinklife then
            if math.floor( self.life * 10 ) % 2 == 1 then
                self.tokenAnimate:draw(self.sprite, self.position.x, self.position.y)
            end
        else
            self.tokenAnimate:draw(self.sprite, self.position.x, self.position.y)
        end
    end
end

return Token