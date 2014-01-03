local Enemy = require 'nodes/enemy'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'canister',
  position_offset = { x = 0, y = 0 },
  height = 24,
  width = 24,
  damage = 0,
  hp = 12,
  vulnerabilities = {'blunt'},
  knockback = 0,
  animations = {
    dying = {
      right = {'once', {'1,2'}, 0.25},
      left = {'once', {'1,2'}, 0.25}
    },
    default = {
      right = {'loop', {'2,1'}, 0.25},
      left = {'loop', {'2,2'}, 0.25}
    },
    hurt = {
      right = {'loop', {'2,1'}, 0.25},
      left = {'loop', {'2,2'}, 0.25}
    }
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.wipeMax = 30
    enemy.wipeCount = 0
    enemy.lastSpawn = 0
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    enemy.lastSpawn = enemy.lastSpawn + dt

    local direction = player.position.x > enemy.position.x and -1 or 1
    enemy.direction = direction == 1 and 'right' or 'left'

    if math.abs(enemy.position.x - player.position.x) < 150 and enemy.wipeCount < enemy.wipeMax and enemy.lastSpawn > 3 then
      enemy.lastSpawn = 0
      local node = {
        x = enemy.position.x,
        y = enemy.position.y,
        type = 'enemy',
        properties = {
          enemytype = 'wipe'
        }
      }
      local wipe = Enemy.new(node, enemy.collider, enemy.type)
      wipe.velocity.x = math.random(20,60)*direction
      wipe.velocity.y = -math.random(300,400)
      wipe.state = 'enter'
      enemy.containerLevel:addNode(wipe)
      enemy.wipeCount = enemy.wipeCount + 1
    end

  end
}