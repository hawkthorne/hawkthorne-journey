local game = require 'game'
local Timer = require 'vendor/timer'

return{
  name = 'birdbomb',
  type = 'projectile',
  lift = 0, 
  friction = 0,
  width = 9,
  height = 9,
  frameWidth = 9,
  frameHeight = 9,
  solid = true,
  velocity = { x=0, y=0 },
  throwVelocityX = 100,
  throwVelocityY = 0,
  damage = 30,
  thrown = true,
  stayOnScreen = false,
  throw_sound = 'acorn_bomb',
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  animations = {
    default = {'loop', {'1,1'}, 0.2},
    thrown = {'loop', {'1,1'}, 0.2},
    finish = {'loop', {'1,1'}, 0.2},
  },
  update = function(dt, projectile)
    
  end,
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if not node.isPlayer then return end
    if projectile.thrown then
    node:hurt(projectile.damage)
    projectile:die()
    end
  end,
  floor_collide = function(node,new_y, projectile)
    projectile:die()
  end,
  leave = function(projectile)
  projectile:die()
  end,
}
