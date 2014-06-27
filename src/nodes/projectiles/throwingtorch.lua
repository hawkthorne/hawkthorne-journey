local game = require 'game'
return{
  name = 'throwingtorch',
  type = 'projectile',
  friction = 0.01 * game.step,
  width = 24,
  height = 44,
  frameWidth = 42,
  frameHeight = 44,
  solid = true,
  lift = 0.3 * game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  velocity = { x = 0, y = 0 }, --initial velocity
  throwVelocityX = 400, 
  throwVelocityY = -300,
  stayOnScreen = false,
  thrown = false,
  throw_sound = 'fire_thrown',
  damage = 2,
  special_damage = {fire = 1},
  horizontalLimit = 400,
  animations = {
    default = {'loop', {'1-6,1'},0.09},
    thrown = {'loop', {'7-13,1'}, 0.09},
    finish = {'once', {'1,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isPlayer then return end
    if node.hurt and projectile.thrown then
      node:hurt(projectile.damage, projectile.special_damage, 0)
      projectile:die()
    end
  end,
}
