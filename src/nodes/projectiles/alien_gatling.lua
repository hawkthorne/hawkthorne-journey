local game = require 'game'
return{
  name = 'alien_gatling',
  type = 'projectile',
  lift = game.gravity,
  width = 13,
  height = 3,
  frameWidth = 13,
  frameHeight = 3,
  solid = true,
  velocity = { x=500, y=0},
  throwVelocityX = -300, 
  throwVelocityY = 0,
  damage = 12,
  stayOnScreen = false,
  horizontalLimit = 420,
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,

  update = function(node, projectile)
  projectile.thrown = true
  end,

  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isEnemy then 
      if node.props.name == 'goat' then 
        node:hurt(projectile.damage, projectile.special_damage, 0) 
        projectile:die()
        else return end
    end
    if node.hurt then
      node:hurt(projectile.damage, projectile.special_damage, 0)
      projectile:die()
    end
  end,

  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}