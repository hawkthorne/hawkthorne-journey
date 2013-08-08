local anim8 = require 'vendor/anim8'
local window = require 'window'
local sound = require 'vendor/TEsound'

local Bottle = {}
Bottle.__index = Bottle

local bottleImage = love.graphics.newImage('images/throwable/bottle.png')
local bottleExplode= love.graphics.newImage('images/throwable/bottle_explode.png')
local g = anim8.newGrid(7, 15, bottleExplode:getWidth(), bottleExplode:getHeight())

function Bottle.new(node, collider)
    local bottle = {}
    setmetatable(bottle, Bottle)
    bottle.image = bottleImage
    bottle.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    bottle.bb.node = bottle
    bottle.collider = collider
    bottle.collider:setPassive(bottle.bb)
    bottle.explode = anim8.newAnimation('once', g('1-5,1'), .10)

    bottle.position = { x = node.x, y = node.y }
    bottle.velocity = { x = 0, y = 0 }

    bottle.floor = 0
    bottle.die = false
    bottle.thrown = false
    bottle.held = false

    bottle.width = node.width
    bottle.height = node.height

    return bottle
end

function Bottle:draw()
    if self.die then
        self.explode:draw(bottleExplode, self.position.x, self.position.y)
    else
        love.graphics.draw(self.image, self.position.x, self.position.y)
    end
end

function Bottle:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer and not self.die then
        node:registerHoldable(self)
    end
end

function Bottle:collide_end(node, dt)
    if node.isPlayer then
        node:cancelHoldable(self)
    end
end

function Bottle:update(dt, player)
    if self.held then
--        self.position.x = math.floor(player.position.x + (self.width / 2)) + 2
--        self.position.y = math.floor(player.position.y + player._hand_right[2] - self.height)

--need to move this later

	self.holdXOffset= 5
	self.holdYOffset = 0

--	self.position.x = math.floor(player.position.x + (self.width / 2)) + self.holdXOffset
--      self.position.y = math.floor(player.position.y + player.offset_hand_right[2] - self.height) + self.holdYOffset

	self.position.x = math.floor(player.position.x + 7) + 5
        self.position.y = math.floor(player.position.y + player.offset_hand_right[2] - 15)

        self:moveBoundingBox()
        return
    end
    
    if self.die and self.explode.position ~= 5 then
        self.explode:update(dt)
        self.position.x = self.position.x + (self.velocity.x > 0 and 1 or -1) * 50 * dt
        return
    end

    if not (self.thrown or self.held) then
        return
    end

    self.velocity.y = self.velocity.y + 0.21875 * 10000 * dt

    if not self.held then
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
    end

    local lwx, rwx = player.footprint:getWall_x()
    if self.position.x < lwx then
        self.velocity.x = -self.velocity.x
    end

    if self.position.x > rwx - self.width then
        self.velocity.x = -self.velocity.x
    end

    if self.thrown and self.position.y > self.floor then
        player:cancelHoldable( self )
        self.position.y = self.floor
        self.thrown = false
        self.die = true
        sound.playSfx('pot_break')
    end
end

function Bottle:moveBoundingBox()
    if not self.bb then return end
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (self.height / 2) + 2)
end

function Bottle:pickup(player)
    self.held = true
    self.velocity.y = 0
    self.velocity.x = 0
end

function Bottle:throw(player)
    self.held = false
    self.thrown = true
    self.floor = player.footprint and player.footprint.y - self.height
    self.velocity.x = player.velocity.x + ((player.character.direction == "left") and -1 or 1) * 500
    self.velocity.y = player.velocity.y
    self.collider:remove(self.bb)
    player:cancelHoldable(self)
end

function Bottle:throw_vertical(player)
    self.held = false
    self.thrown = true
    self.floor = player.footprint and player.footprint.y - self.height
    self.velocity.x = player.velocity.x
    self.velocity.y = player.velocity.y - 500
    self.collider:remove(self.bb)
    player:cancelHoldable(self)
end

function Bottle:drop(player)
    self.held = false
    self.thrown = false
    self.position.y = player.footprint and player.footprint.y - self.height
    self.velocity.x = 0
    self.velocity.y = 0
    self:moveBoundingBox()
    player:cancelHoldable(self)
end

return Bottle
