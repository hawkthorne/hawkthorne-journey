local game = require 'game'
return{
  name = 'benzalkFire',
  type = 'projectile',
  friction = 1, --0.01 * game.step,
  width = 72,
  height = 33,
  frameWidth = 72,
  frameHeight = 33,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  velocity = { x = 0, y = 0 }, --initial velocity
  throwVelocityX = 300,
  throwVelocityY = 0,
  thrown = false,
  damage = 10,
  special_damage = {fire = 10},
  horizontalLimit = 1000,
  throw_sound = 'fireball',
  animations = {
    default = {'once', {'1,1'},1},
    thrown = {'loop', {'1-4,1'}, .25},
    finish = {'once', {'4,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
  if node.isEnemy then return end
    if node.hurt then
      node:hurt(projectile.damage, projectile.special_damage, 0)
      projectile:die()
    end
  end,
}