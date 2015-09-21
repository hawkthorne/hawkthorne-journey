local anim8 = require 'vendor/anim8'
local app = require 'app'
local game = require 'game'
local gamestate = require 'vendor/gamestate'
local utils = require 'utils'
local collision  = require 'hawk/collision'
local Timer = require 'vendor/timer'

local Fire = {}
Fire.__index = Fire
Fire.isFire = true

local image = love.graphics.newImage('images/fire_cornelius_small.png')
image:setFilter('nearest', 'nearest')

local g = anim8.newGrid(25, 25, image:getWidth(), image:getHeight())

local states = {
  burning = anim8.newAnimation('loop', g('1-8,1'), 0.5)
}

---
-- Creates a new Fire object
-- @param parent the parent node that the fire are added to
function Fire.new(node, collider, position)
  local fire = {}
  setmetatable(fire, Fire)
  fire.node = node
  fire.collider = collider

  fire.state = 'burning'

  fire.x = node.x
  fire.y = node.y
  fire.velocity = {x=0, y=0}
  --fire.special_damage = {stab = 2},
  fire.width = 25
  fire.height = 25

  fire.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  fire.bb.node = fire
  collider:setSolid(fire.bb)

  fire.damage = 6
  fire.special_damage = {fire = 10 }

  return fire
end

function Fire:die()
  local current = gamestate.currentState()
  local level = self.node.containerLevel

  if level.name ~= current.name or not level.map then return end
  self.dead = true
  self.collider:remove(self.bb)

  local SpriteClass = require 'nodes/sprite'
  local node = {
    x = self.x,
    y = self.y,
    width = level.map.tilewidth,
    height = level.map.tileheight,
    properties = {
      animation = "1-4,1",
      speed = "0.25",
      sheet = 'images/steam.png',
      width = level.map.tilewidth,
      height = level.map.tileheight,
      mode = 'loop'
    }
  }
  local steam = SpriteClass.new(node)
  level:addNode(steam)
  Timer.add(math.random(3,5), function()
    level:removeNode(steam)
  end)
end

function Fire:collide(node, dt, mtv_x, mtv_y, collider)
  if self.dead then return end
  if not node.isEnemy then
    if node.hurt then
      node:hurt(self.damage, self.special_damage)
    end
  end
end

function Fire:floor_pushback(node, new_y)
  --self.y = new_y
  self.velocity.y = 0
  self:update_bb()    
end

function Fire:update(dt, player, map)
	if self.dead then return end

  if not self.dying then
    self.dying = true
    Timer.add(math.random(8,10), function()
      self:die()
    end)
  end
	
  if self.velocity.y > game.max_y then
    self.velocity.y = game.max_y
  end
  
  self:update_bb()

  states[self.state]:update(dt)


  local nx, ny = collision.move(map, self, self.x, self.y,
                                  self.width, self.height, 
                                  self.velocity.x * dt, self.velocity.y * dt)
  self.x = nx
  self.y = ny

  -- X velocity won't need to change
  self.velocity.y = self.velocity.y + game.gravity*dt
end

function Fire:update_bb()
  self.bb:moveTo(self.x + self.width / 2 , self.y + self.height / 2)
end

function Fire:draw()
	if self.dead then return end
  states[self.state]:draw(image, self.x, self.y)
end

return Fire
