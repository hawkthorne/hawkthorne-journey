local game = require 'game'
local Timer = require 'vendor/timer'

return{
  name = 'money',
  type = 'projectile',
  friction = 0,
  width = 28,
  height = 20,
  frameWidth = 14,
  frameHeight = 20,
  velocity = { x=0, y=1 },
  damage = 0,
  thrown = true,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = false,
  update = function(dt, projectile)
    projectile.velocity.y = 150 + math.random() * 10
  end,
  floor_collide = function(projectile)
    if not projectile.complete then
      projectile.collider:setGhost(projectile.bb)
      projectile.collider:remove(projectile.bb)
      projectile:finish()
    end
  end,
  animations = {
    default = {'loop', {'1-2,1'}, 0.2},
    thrown = {'loop', {'1-2,1'}, 0.2},
    finish = {'loop', {'2-2,1'}, 0.2},
  }
}
