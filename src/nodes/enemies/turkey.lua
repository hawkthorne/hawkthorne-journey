local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'turkey',
  height = 72,
  width = 72,
  damage = 30,
  jumpkill = true,
  last_jump = 0,
  bb_width = 50,
  bb_height = 30,
  bb_offset = {x=4, y=22},
  velocity = {x = -20, y = 0},
  hp = 8,
  vel_x = { min = 10, max = 100},
  vel_y = { min = 200, max = 600},
  vel_y_spawn = { min = 200, max = 1000},
  vulnerabilities = {'slash'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    jump = {
      right = {'loop', {'3-4,2'}, 0.25},
      left = {'loop', {'3-4,1'}, 0.25}
    },
    default = {
      right = {'loop', {'1-2,2'}, 0.25},
      left = {'loop', {'1-2,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1-2,2'}, 0.25},
      left = {'loop', {'1-2,1'}, 0.25}
    },
    dying = {
      right = {'once', {'1-4,3'}, 0.25},
      left = {'once', {'1-4,3'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction = player.position.x > enemy.position.x and -1 or 1

    enemy.last_jump = enemy.last_jump + dt
    if enemy.last_jump > 2.5+math.random() then
      enemy.state = 'jump'
      enemy.last_jump = 0
      enemy.velocity.y = -math.random(enemy.props.vel_y.min, enemy.props.vel_y.max)
      enemy.velocity.x = math.random(enemy.props.vel_x.min, enemy.props.vel_x.max)*direction
      enemy.turkeyCount = enemy.turkeyCount or 0
      enemy.turkeyMax = enemy.turkeyMax or 1
      if math.random(2) == 1 and math.abs(player.position.x - enemy.position.x) < 250 and
                      enemy.turkeyCount < enemy.turkeyMax then
        enemy.turkeyCount = enemy.turkeyCount + 1
        local node = {
          x = enemy.position.x,
          y = enemy.position.y,
          height = enemy.height,
          width = enemy.width,
          type = 'enemy',
          properties = {
              enemytype = 'turkey'
          }
        }
        local spawnedTurkey = Enemy.new(node, enemy.collider, enemy.type)
        spawnedTurkey.turkeyMax = enemy.turkeyMax - 1
        spawnedTurkey.velocity.x = math.random(enemy.props.vel_x.min, enemy.props.vel_x.max)*direction
        spawnedTurkey.velocity.y = -math.random(enemy.props.vel_y_spawn.min, enemy.props.vel_y_spawn.max)
        spawnedTurkey.last_jump = 1
        enemy.containerLevel:addNode(spawnedTurkey)
      end
    end
    if enemy.velocity.y == 0 and enemy.state ~= 'attack' then
      enemy.state = 'default'
    end
    --start moving in a direction once you escape the wall
    if enemy.state=='jump' and enemy.velocity.x==0 then
      enemy.velocity.x = enemy.props.vel_x.max * direction
    end

    if enemy.velocity.x > 0 then
      enemy.direction = 'right'
    elseif enemy.velocity.x < 0 then
      enemy.direction = 'left'
    end

  end
}