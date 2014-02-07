local game = require 'game'
return{
  name = 'throwingknife',
  type = 'projectile',
  friction = 1, --0.01 * game.step,
  width = 16,
  height = 16,
  frameWidth = 24,
  frameHeight = 24,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  velocity = { x = -230, y = 0 }, --initial velocity
  throwVelocityX = 400, 
  throwVelocityY = 0,
  stayOnScreen = false,
  thrown = false,
  damage = 1,
  special_damage = {stab = 1},
  horizontalLimit = 600,
  animations = {
    default = {'once', {'1,1'},1},
    thrown = {'once', {'1,1'}, 1},
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
