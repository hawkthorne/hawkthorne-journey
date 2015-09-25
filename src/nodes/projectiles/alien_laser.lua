local game = require 'game'
return{
  name = 'alien_laser',
  type = 'projectile',
  lift = game.gravity,
  width = 17,
  height = 5,
  frameWidth = 17,
  frameHeight = 5,
  solid = true,
  velocity = { x=500, y=0},
  throwVelocityX = -300, 
  throwVelocityY = 0,
  damage = 10,
  stayOnScreen = false,
  horizontalLimit = 420,
  special_damage = {blunt = 1},
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  throw_sound = 'maincorn_beam',

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
    if node.isBuilding and node.burn then
      node:burn(projectile.position.x, projectile.position.y)
    end
  end,

  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}