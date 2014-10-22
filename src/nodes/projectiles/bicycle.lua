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
  floor_collide = function(projectile)
    projectile.collider:setGhost(projectile.bb)
    -- Bounce slightly
    projectile.velocity.y = -30
    -- Stop collision detection
    projectile.width = 0
    projectile.height = 0
  end,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}
