local game = require 'game'
return{
  name = 'lasercell',
  type = 'projectile',
  width = 17,
  height = 5,
  frameWidth = 17,
  frameHeight = 5,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  usedAsAmmo = true,
  throw_sound = 'alien_laser',
  velocity = { x = -600, y = 0 }, --initial velocity
  throwVelocityX = 600, 
  throwVelocityY = 0,
  thrown = false,
  damage = 5,
  throw_x = -2,
  throw_y = -11,
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
