local game = require 'game'
return{
  name = 'bomb',
  type = 'projectile',
  lift = game.gravity,
  width = 9,
  height = 9,
  frameWidth = 9,
  frameHeight = 9,
  solid = true,
  velocity = { x=500, y=0},
  throwVelocityX = -300, 
  throwVelocityY = 0,
  damage = 20,
  stayOnScreen = false,
  horizontalLimit = 30000,
  special_damage = {blunt = 1},
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,

  update = function(node, projectile)
  projectile.thrown = true
  end,

  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isEnemy then return end
    if node.isPlayer and node.hurt then
      node:hurt(projectile.damage)
      projectile:die()
    end
  end,

  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}
