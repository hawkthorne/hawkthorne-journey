local game = require 'game'
return{
  name = 'fireball',
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
  velocity = { x = -230, y = 0 }, --initial velocity
  throwVelocityX = 760, 
  throwVelocityY = 0,
  thrown = false,
  damage = 10,
  special_damage = {fire = 10},
  horizontalLimit = 600,
  animations = {
    default = {'once', {'1,1'},1},
    thrown = {'once', {'1-2,1'}, .25},
    finish = {'once', {'1,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isPlayer then return end
    if node.hurt then
      node:hurt(projectile.damage, projectile.special_damage, 0)
      projectile:die()
    end
  end,
}