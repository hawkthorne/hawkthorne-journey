local game = require 'game'
return{
  name = 'acornBomb',
  type = 'projectile',
  friction = 0.01 * game.step,
  width = 15,
  height = 15 ,
  frameWidth = 15,
  frameHeight = 15,
  solid = true,
  handle_x = 10,
  handle_y = -6,
  lift = 0,
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  velocity = { x = 0, y = 0 }, --initial vel isn't used since this is insantly picked up
  throwVelocityX = math.random(400,500),
  throwVelocityY = math.random(-100,-200),
  stayOnScreen = false,
  damage = 10,
  idletime = 0,
  horizontalLimit = 400,
  throw_sound = 'acorn_throw',
  animations = {
    default = {'loop', {'1,1'}, 0.2},
    thrown = {'once', {'1,1'}, 0.1},
    finish = {'once', {'2,1','3,1','4,1','5,1'}, .1},
  },

  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if not node.isPlayer then return end
    if projectile.thrown then
      node:hurt(projectile.damage)
      projectile:die()
    end
  end,

  leave = function(projectile)
    projectile:die()
  end,
}