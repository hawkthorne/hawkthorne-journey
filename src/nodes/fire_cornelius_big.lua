local anim8 = require 'vendor/anim8'
local app = require 'app'
local game = require 'game'
local utils = require 'utils'
local collision  = require 'hawk/collision'

local Fireball = {}
Fireball.__index = Fireball
Fireball.isFireball = true

local image = love.graphics.newImage('images/fire_cornelius_big.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(34, 110, image:getWidth(), image:getHeight())

local states = {
  burning = anim8.newAnimation('loop', g('1-4,1'), 0.1)
}

---
-- Creates a new Fire object
-- @param parent the parent node that the fire are added to
function Fireball.new(node, collider, level)
  local fireball = {}
  setmetatable(fireball, Fireball)
  fireball.node = node
  fireball.collider = collider

  fireball.state = 'burning'

  fireball.x = node.x
  fireball.y = node.y
  fireball.velocity = {x=0, y=0}
  --fireball.special_damage = {stab = 2},
  fireball.width = 34
  fireball.height = 110

  fireball.bb = collider:addRectangle(node.x, node.y, fireball.width, fireball.height)
  fireball.bb.node = fireball
  collider:setSolid(fireball.bb)

  fireball.hp = 5
  fireball.dead = false
  fireball.damage = 20
  fireball.special_damage = {fire = 20 }

  return fireball
end

function Fireball:collide(node, dt, mtv_x, mtv_y, collider, level)
  if self.dead then return end
  if not node.isEnemy then
    if node.hurt then
      node:hurt(self.damage, self.special_damage)
    end
    self:spawn(node, collider, level)
    self.dead = true
    self.collider:remove(self.bb)
  end
end

function Fireball:floor_pushback(node, new_y)
  --self.y = new_y
  self.velocity.y = 0
  self:update_bb()
end

function Fireball:spawn(node, collider, level)
  local spawnRight = (math.random(1,3))
  local spawnLeft = (math.random(1,3))
  local level = self.containerLevel
  for i = 1, spawnRight do
    local Fire = require('nodes/fire_cornelius_small')
    local node = {
      type = 'fire_cornelius_small',
      name = 'smallFire',
      x = self.x+(20*i),
      y = self.y+self.height,
      width = 20,
      height = 25,
      containerLevel = level,
      properties = {}
    }
    local smallFire = Fire.new( node, self.collider )
    level:addNode(smallFire)
  end
  for i = 1, spawnLeft do
    local Fire = require('nodes/fire_cornelius_small')
    local node = {
      type = 'fire_cornelius_small',
      name = 'smallFire',
      x = self.x-(20*i),
      y = self.y+self.height,
      width = 20,
      height = 25,
      containerLevel = level,
      properties = {}
    }
    local smallFire = Fire.new( node, self.collider )
    level:addNode(smallFire)
  end
  local Fire = require('nodes/fire_cornelius_small')
  local node = {
    type = 'fire_cornelius_small',
    name = 'smallFire',
    x = self.x,
    y = self.y+self.height,
    width = 20,
    height = 25,
    containerLevel = level,
    properties = {}
  }
  local smallFire = Fire.new( node, self.collider )
  level:addNode(smallFire)
end

function Fireball:update(dt, player, map)
	if self.dead then return end

  --self.velocity.y = self.velocity.y + game.gravity * dt

  if self.velocity.y > game.max_y then
    self.velocity.y = game.max_y
  end

  --self.y = self.y + (self.velocity.y * dt)
  self:update_bb()

  states[self.state]:update(dt)


  local nx, ny = collision.move(map, self, self.x, self.y,
                                  self.width, 108, 
                                  self.velocity.x * dt, self.velocity.y * dt)
  self.x = nx
  self.y = ny

  -- X velocity won't need to change
  self.velocity.y = self.velocity.y + (game.gravity*(2/3))*dt
end

function Fireball:update_bb()
  self.bb:moveTo(self.x + self.width / 2 , self.y + self.height / 2)
end

function Fireball:draw()
	if self.dead then return end
  states[self.state]:draw(image, self.x, self.y)
end

return Fireball
