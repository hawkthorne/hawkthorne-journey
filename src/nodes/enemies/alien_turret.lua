local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Projectile = require 'nodes/projectile'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Quest = require 'quest'

return {
  name = 'alien_turret',
  die_sound = 'boulder-crumble',
  height = 48,
  width = 48,
  damage = 25,
  bb_width = 31,
  bb_height = 35,
  bb_offset = {x=0, y=5},
  chargeUpTime = 0,
  --bb_offset = {x=0, y=0},
  velocity = {x = 0, y = 0},
  hp = 5,
  tokens = 6,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'loop', {'2-4,1'}, 0.2},
      left = {'loop', {'4-2,2'}, 0.2}
    },
    default = {
      right = {'loop', {'1,1'}, 0.2},
      left = {'loop', {'4,2'}, 0.2}
    },
    shooting = {
      right = {'loop', {'1,1'}, 0.2},
      left = {'loop', {'4,2'}, 0.2}
    },
  },

  laserAttack = function( enemy, direction, player )
  enemy.state = 'shooting'
    local node = {
      type = 'projectile',
      name = 'alien_gatling',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 17,
      height = 5,
      properties = {}
    }
    local laser = Projectile.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(laser)
    laser.velocity.x = 200*direction
    laser.velocity.y = math.random(-10,10)
    laser.position.x = enemy.position.x +15
    laser.position.y = enemy.position.y + 24
    Timer.add(0.1, function()
    enemy.state = 'default'
    end)
  end,
  update = function( dt, enemy, player, level )

  if math.abs(enemy.position.x - player.position.x) < 300 then
      if enemy.position.x > player.position.x then
      enemy.direction = 'left'
      else
      enemy.direction = 'right'
      end
      enemy.idletime = enemy.idletime + dt
      enemy.chargeUpTime = enemy.chargeUpTime + dt
      --laser attack
      local direction = player.position.x > enemy.position.x and 1 or -1
      if enemy.idletime >= 0.1 then
        if enemy.chargeUpTime >= 1 then
          Timer.add(1, function()
            enemy.idletime = 0
            enemy.chargeUpTime = 0
            end)
        else
        sound.playSfx( 'alien_gatling' )
        enemy.props.laserAttack(enemy, direction, player)
        enemy.idletime = 0
        end
      end
    end
  end
}