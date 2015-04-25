local anim8 = require 'vendor/anim8'
local app = require 'app'
local game = require 'game'
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

  fire.hp = 1
  fire.hurtBy = {'water'}
  fire.dead = false
  fire.damage = 2
  fire.special_damage = {fire = 2 }
  fire.enterTimer = false

  return fire
end

function Fire:enter()
  print('enter')
  Timer.add(2, function()
    self.dead = true
    end)
end

function Fire:collide(node, dt, mtv_x, mtv_y, collider)
  if self.dead or node.isSpawn then return end
  if not node.isEnemy or node.isSpawn then 
    if not self.enterTimer then
        Timer.add(10, function() self.dead = true self.collider:remove(self.bb) end)
        self.enterTimer = true
    end
    if node.hurt then
      node:hurt(self.damage, self.special_damage)
    end
    if node.burn then
      node:burn(self.x,self.y)
      self:spawn()
    end
  end
  

end

function Fire:floor_pushback(node, new_y)
  --self.y = new_y
  self.velocity.y = 0
  self:update_bb()    
end

function Fire:spawn()
end

function Fire:update(dt, player, map)
	if self.dead then return end
	
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

function Fire:hurt( damage, special_damage )
    self.hp = self.hp - self:calculateDamage(damage, special_damage)
    if self.hp <= 0 then
        self.dead = true
        self.collider:remove(self.bb)
    end
end

function Fire:calculateDamage(damage, special_damage, player)
    if not self:specialDamageCheck(special_damage) then 
        return 0 

    end

    return damage
end

function Fire:specialDamageCheck( special_damage )
    if not self.hurtBy or self.hurtBy == {} then 
        return true 
    end

    if special_damage and special_damage[self.hurtBy] ~= nil then
      print('fire is hurt')
        return true
    end

    return false
end

function Fire:update_bb()
    self.bb:moveTo(self.x + self.width / 2 , self.y + self.height / 2)
    --[[local x1,y1,x2,y2 = self.bb:bbox()
            self.bb:moveTo( self.x + (x2-x1)/2 ,
                            self.y + (y2-y1)/2 )]]
end

function Fire:draw()
	if self.dead then return end
    states[self.state]:draw(image, self.x, self.y)
end

return Fire
