local game = require 'game'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
  name = 'waterSpout',
  type = 'projectile',
  friction = 1,
  width = 24,
  height = 16,
  frameWidth = 24,
  frameHeight = 72,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  --usedAsAmmo = true,
  velocity = { x = 0, y = game.gravity }, --initial velocity
  throwVelocityX = 200,
  throwVelocityY = 0,
  drawoffset = { x = 0, y = -43 },
  offset = { x = 0, y = 0 },
  handle_y = 50,
  stayOnScreen = false,
  thrown = false,
  damage = 5,
  special_damage = {water= 6, epic = 100},
  max_damage = 15,
  horizontalLimit = 600,
  explosive = true,
  explodeTime = 1,
  explode_sound = 'explosion_quiet',
  animations = {
    default = {'loop', {'1-4,1'}, 0.15},
    thrown = {'loop', {'1-4,1'}, 0.15},
    explode = {'once', {'5-15,1'}, .08},
    finish = {'once', {'15,1'}, 1},
  },

  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if node.isPlayer then return end
    if node.isEnemy then
      Timer.add(.1, function () 
        projectile.velocity.x =0
        if projectile.props.explode_sound then
          sound.playSfx( projectile.props.explode_sound )
        end
      end)
      projectile.animation = projectile.explodeAnimation
      Timer.add(projectile.explodeTime, function () 
        projectile:die()
      end)
    end
    if node.hurt then
      node:hurt(projectile.damage, projectile.special_damage, 0)
    end
  end,
}
