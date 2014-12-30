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
  horizontalLimit = 420,
  special_damage = {blunt = 1},
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  throw_sound = 'acorn_bomb',
  spawn_sound = 'acorn_bomb',

  update = function(node, projectile)
  projectile.thrown = true
  if projectile.velocity.x == 0 and projectile.velocity.y == 0 then
    projectile:die()
  end
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
