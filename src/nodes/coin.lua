local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local game = require 'game'

local Coin = {}
Coin.__index = Coin

local coinsprite = love.graphics.newImage('images/coin.png')
local bling = anim8.newGrid(8, 9, coinsprite:getWidth(), coinsprite:getHeight())
 
function Coin.new(x,floory, collider, value)
    local coin = {}
    setmetatable(coin, Coin)

    coin.collider = collider

    coin.foreground = true

    coin.position = { x=x, y=floory }
    coin.velocity = { x=(math.random(30)-15)*30, y=-175 }

    coin.value = value
    coin.life = 5
    coin.blinklife = 2
    coin.speed = 300
    coin.active = true

    coin.floory = floory

    coin.bb = collider:addRectangle(coin.position.x, coin.position.y, 8,9)
    coin.bb.node = coin

    coin.coinAnimate = anim8.newAnimation('loop', bling('1-2,1'), 0.3)

    collider:setPassive(coin.bb)

    return coin
end

function Coin:update(dt, player)
    if self.active then
        self.life = self.life - dt
        if self.life < 0 then
            self.active = false
        end
            
        self.coinAnimate:update(dt)

        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.airaccel * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.airaccel * dt, 0)
        end

        self.velocity.y = self.velocity.y + game.gravity / 2 * dt

        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt

        if self.position.y + 9 > self.floory then
            self.position.y = self.floory - 9
        end

        self.bb:moveTo(self.position.x + 4, self.position.y + 4)
    end
end

function Coin:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        local player = node
        if self.active then
            sound.playSfx('pickup')
            self.active = false
            player.money = player.money + self.value
            self.collider:setGhost(self.bb)
        end
    end
end

function Coin:draw()
    if self.active then
        if self.life <= self.blinklife then
            if math.floor( self.life * 10 ) % 2 == 1 then
                self.coinAnimate:draw(coinsprite, self.position.x, self.position.y)
            end
        else
            self.coinAnimate:draw(coinsprite, self.position.x, self.position.y)
        end
    end
end

return Coin