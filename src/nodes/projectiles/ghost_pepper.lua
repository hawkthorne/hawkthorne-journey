local game = require 'game'
local Timer = require 'vendor/timer'
return{
  name = 'ghost_pepper',
  type = 'projectile',
  friction = 1,
  width = 63,
  height = 74,
  frameWidth = 63,
  frameHeight = 74,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = false,
  velocity = { x = 0, y = 0 }, --initial velocity
  throwVelocityX = 100,
  throwVelocityY = -1,
  offset = { x = 15, y = -15},
  stayOnScreen = false,
  thrown = false,
  damage = 5,
  special_damage = {ice = 2, fire = 2},
  max_damage = 15,
  horizontalLimit = 600,
  explosive = true,
  explodeTime = 1,
  explode_sound = 'explosion_quiet',
  animations = {
    default = {'loop', {'1-3,1','2,1'}, 0.3},
    thrown = {'loop', {'1-3,1','2,1'}, 0.3},
    explode = {'once', {'4-15,1'}, .08},
    finish = {'once', {'15,1'}, 1},
  },
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isPlayer then return end
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
