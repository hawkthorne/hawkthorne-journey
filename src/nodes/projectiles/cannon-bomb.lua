local game = require 'game'
return{
  name = 'cannon-bomb',
  type = 'projectile',
width = 9,
height = 9,
frameWidth = 9,
frameHeight = 9,
solid = true,
lift = 0,
playerCanPickUp = false,
enemyCanPickUp = true,
canPlayerStore = false,
velocity = { x = 0, y = 0 }, --initial vel isn't used since this is insantly picked up
throwVelocityX = 1,
throwVelocityY = 1,
stayOnScreen = false,
horizontalLimit = 300,
damage = 40,
idletime = 0,
throw_sound = 'acorn_bomb',

collide = function(node, dt, mtv_x, mtv_y,projectile)
projectile.animation = projectile.finishAnimation
if not node.isPlayer then return end
if projectile.thrown then
node:hurt(projectile.damage)
projectile:die()
end
end,
update = function(dt,projectile)
projectile.thrown = true
end,
enter = function(dt,projectile)
projectile.thrown = true
end,
leave = function(projectile)
projectile:die()
end,

  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}
