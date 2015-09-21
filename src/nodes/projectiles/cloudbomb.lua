local game = require 'game'
return{
  name = 'cloudbomb',
  type = 'projectile',
  friction = 0.01 * game.step,
  width = 9,
  height = 9,
  frameWidth = 9,
  frameHeight = 9,
  handle_x = 5,
  handle_y = 5,
  solid = true,
  lift = 1,
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  velocity = { x = 0, y = 0 }, --initial vel isn't used since this is insantly picked up
  throwVelocityX = 400,
  throwVelocityY = math.random(-300,300),
  stayOnScreen = false,
  horizontalLimit = 300,
  damage = math.random(10,15),
  idletime = 0,
  throw_sound = 'acorn_bomb',
  animations = {
    default = {'once', {'1,1'}, 0.2},
    thrown = {'loop', {'10-13,1'}, 0.2},
    finish = {'once', {'9-1,1'}, 0.22},
  },

  collide = function(node, dt, mtv_x, mtv_y,projectile)
    projectile.animation = projectile.finishAnimation
    if not node.isPlayer then return end
    if projectile.thrown then
      if node.direction == 'left' then
        node.velocity.x = projectile.knockback
      else
        node.velocity.x = -projectile.knockback
      end
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
}