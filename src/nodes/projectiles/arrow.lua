local game = require 'game'
return{
  name = 'arrow',
  type = 'projectile',
  friction = 1,
  width = 27,
  height = 7,
  frameWidth = 27,
  frameHeight = 7,
  solid = true,
  lift = game.gravity * 0.88,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  usedAsAmmo = true,
  throw_sound = 'arrow',
  velocity = { x = -600, y = 0 }, --initial velocity
  throwVelocityX = 600, 
  throwVelocityY = -30,
  stayOnScreen = false,
  thrown = false,
  damage = 2,
  special_damage = {stab = 1},
  horizontalLimit = 800,
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
