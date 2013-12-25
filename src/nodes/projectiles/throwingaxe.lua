local game = require 'game'
return{
  name = 'throwingaxe',
  type = 'projectile',
  friction = 0.01 * game.step,
  width = 16,
  height = 16,
  frameWidth = 24,
  frameHeight = 24,
  solid = true,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  velocity = { x = 0, y = 0 }, --initial velocity
  throwVelocityX = 400, 
  throwVelocityY = -550,
  stayOnScreen = false,
  thrown = false,
  damage = 2,
  special_damage = {slash = 1},
  horizontalLimit = 300,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'loop', {'1,1', '2,1','3,1','4,1','5,1','6,1','7,1'}, 0.15},
    finish = {'once', {'3,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isPlayer then return end
    if node.hurt then
      node:hurt(projectile.damage, projectile.special_damage, 0)
      projectile:die()
    end
  end
}
