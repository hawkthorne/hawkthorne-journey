local collision  = require 'hawk/collision'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local game = require 'game'
local utils = require 'utils'

local Token = {}
Token.__index = Token
 
function Token.new( node, collider)
    local token = {}
    setmetatable(token, Token)

    token.item = require ( 'tokens/' .. node.name )
    token.value = node.properties.value or token.item.value
    assert(token.value,"Token requires a value")
    assert(tonumber(token.value),"Token value must be a number")

    token.height = token.item.height
    token.width = token.item.width

    token.collider = collider

    token.foreground = true

    token.sprite = love.graphics.newImage('images/tokens/' .. node.name .. '.png')
    token.g = anim8.newGrid( token.width, token.height, token.sprite:getWidth(), token.sprite:getHeight())

    token.position = {
        x = node.x + token.width / 2,
        y = node.y - token.height - 5
    }
    token.velocity = {
        x = utils.rsign() * ( (math.random(100) + 10 ) * 3),
        y = -375
    }

    token.life = tonumber(node.properties.life) or math.huge
    token.blinklife = 2
    token.speed = 300
    token.delay = 0.1

    token.bb = collider:addRectangle( token.position.x, token.position.y, token.width, token.height )
    token.bb.node = token

    token.tokenAnimate = anim8.newAnimation( 'loop', token.g( token.item.frames ), token.item.speed )

    -- collider:setPassive(token.bb)

    return token
end

function Token:update(dt, player, map)
    self.delay = self.delay - dt
    if self.delay > 0 then return end
    self.life = self.life - dt
    if self.life < 0 then
        self.collider:remove(self.bb)
        self.containerLevel:removeNode(self)
    end
        
    self.tokenAnimate:update(dt)

    if self.velocity.x < 0 then
        self.velocity.x = math.min(self.velocity.x + ( 0.1 * game.step ) * dt, 0)
    else
        self.velocity.x = math.max(self.velocity.x - ( 0.1 * game.step ) * dt, 0)
    end

    self.velocity.y = self.velocity.y + game.gravity * dt

    local nx, ny = collision.move(map, self, self.position.x, self.position.y,
                                  self.width, self.height, 
                                  self.velocity.x * dt, self.velocity.y * dt)

    self.position.x = nx
    self.position.y = ny
    
    self:moveBoundingBox()
end

function Token:moveBoundingBox()
    self.bb:moveTo(self.position.x + self.height / 2, self.position.y + self.height / 2)
end

function Token:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        local player = node
        sound.playSfx('pickup')
        self.item.onPickup( player, self.value )
        self.collider:remove(self.bb)
        if self.containerLevel then
            self.containerLevel:removeNode(self)
        end
    end
end

function Token:draw()
    if self.delay < 0 then
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
