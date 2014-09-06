local game = require 'game'
local Timer = require 'vendor/timer'

return{
  name = 'computer',
  type = 'projectile',
  bounce_factor = 0.1,
  friction = 0,
  width = 76,
  height = 38,
  frameWidth = 38,
  frameHeight = 38,
  velocity = { x=0, y=100 },
  damage = 0,
  thrown = true,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = false,
  floor_collide = function(projectile)
    projectile.animation = projectile.finishAnimation
    projectile.collider:setGhost(projectile.bb)
    -- Bounce slightly
    projectile.velocity.y = -50
    -- Stop collision detection
    projectile.width = 0
    projectile.height = 0
  end,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'2,1'}, 1},
  }
}
