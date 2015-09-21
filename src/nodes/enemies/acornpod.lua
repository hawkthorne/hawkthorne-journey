local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'acornpod',
  attackDelay = 1,
  height = 24,
  width = 24,
  antigravity = true,
  jumpkill = false,
  damage = 5,
  knockback = 0,
  hp = 1000,
  tokens = 4,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    attack = {
      right = {'loop', {'1-2,1'}, 0.2},
      left = {'loop', {'1-2,1'}, 0.2}
    },
    default = {
      right = {'loop', {'1,1'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1-2,1'}, 0.2},
      left = {'loop', {'1-2,1'}, 0.2}
    },
    dying = {
      right = {'once', {'1-2,1'}, 0.25},
      left = {'once', {'1-2,1'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.spawned = 0
  end,

  spawn_minion = function( enemy, direction )
    local node = {
      x = enemy.position.x,
      y = enemy.position.y,
      type = 'enemy',
      properties = {
          enemytype = 'jumpingacorn'
      }
    }
    local spawnedJumpingacorn = Enemy.new(node, enemy.collider, enemy.type)
    spawnedJumpingacorn.velocity.x = math.random(10,100)*direction
    spawnedJumpingacorn.velocity.y = -math.random(100,200)
    enemy.containerLevel:addNode(spawnedJumpingacorn)
    
  end,





  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction = player.position.x > enemy.position.x + 40 and -1 or 1

    spawnMax = math.random(1,4) 

    if enemy.state == 'hurt'  and enemy.spawned < spawnMax then
      enemy.props.spawn_minion(enemy, direction)
      enemy.spawned = enemy.spawned + 1
    elseif enemy.state == 'attack' and enemy.spawned < spawnMax then
      enemy.props.spawn_minion(enemy, direction)
      enemy.spawned = enemy.spawned + 1
    elseif enemy.state == 'default' and enemy.current_enemy == enemy.name then
        enemy.spawned = 0
    end

  end
}