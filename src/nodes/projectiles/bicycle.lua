local game = require 'game'
return{
  name = 'bicycle',
  type = 'projectile',
  width = 41,
  height = 31,
  frameWidth = 41,
  frameHeight = 31,
  velocity = { x=0, y=150 },
  damage = 0,
  thrown = true,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = false,
  collide = function(node, dt, mtv_x, mtv_y,projectile)
  end,
  collide_end = function(node, dt,projectile)
  end,
  floor_collide = function(node,new_y, projectile)
    projectile.collider:setGhost(projectile.bb)
  end,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}
