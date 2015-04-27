local game = require 'game'
local Timer = require 'vendor/timer'
return{
  name = 'black_lightning',
  type = 'projectile',
  friction = 1,
  width = 100,
  height = 30,
  frameWidth = 100,
  frameHeight = 30,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = false,
  velocity = { x = 0, y = 0 }, --initial velocity
  throwVelocityX = 800,
  throwVelocityY = 0,
  offset = { x = 15, y = -15},
  thrown = false,
  damage = 4,
  special_damage = {lightning = 4},
  max_damage = 20,
  horizontalLimit = 600,
  animations = {
    default = {'loop', {'1-3,1'}, 0.1},
    thrown = {'loop', {'1-3,1'}, 0.1},
    finish = {'once', {'1,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
  if node.isPlayer or node.isInteractive then return end
    if node.hurt then
      -- If the projectile node doesn't have the max_damage attribute yet, set the default
      -- Don't change the projectile.props, since that will change the node for the rest of the lightning nodes.
      if not projectile.max_damage then
        projectile.max_damage = projectile.props.max_damage
      end
      if projectile.max_damage > 0 then
        node:hurt(projectile.damage, projectile.special_damage, 0)
        projectile.max_damage = projectile.max_damage - projectile.props.damage
      else
        projectile:die()
      end
    end
  end,
}
