local Timer = require 'vendor/timer'
local Enemy = require 'nodes/enemy'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'hemp',
  die_sound = 'hemp',
  bb_offset = { x = 2, y = 6},
  bb_width = 30,
  bb_height = 36,
  height = 48,
  width = 48,
  damage = 20,
  hp = 1,
  jumpkill = false,
  --antigravity = true,
  animations = {
    default = {
      right = {'loop', {'1-8,1'}, 0.2},
      left = {'loop', {'1-8,1'}, 0.2}
    },
    dying = {
      right = {'once', {'9-10,1'}, 0.1},
      left = {'once', {'9-10,1'}, 0.1}, 
    },
    hurt = {
      right = {'once', {'9-10,1'}, 0.1},
      left = {'once', {'9-10,1'}, 0.1},    
    },
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

    if math.abs(enemy.position.x - player.position.x) < 300 and enemy.wipeCount < enemy.wipeMax and enemy.lastSpawn > 3.5 then
      enemy.lastSpawn = 0
      local node = {
        x = enemy.position.x,
        y = enemy.position.y,
        type = 'enemy',
        properties = {
          enemytype = 'hempleaf'
        }
      }
      local wipe = Enemy.new(node, enemy.collider, enemy.type)
      wipe.maxx = enemy.position.x + 250
      wipe.minx = enemy.position.x - 250
      wipe.maxy = enemy.position.y + 250
      wipe.miny = enemy.position.y - 250
      wipe.velocity.y = 3
      enemy.containerLevel:addNode(wipe)
      enemy.wipeCount = enemy.wipeCount + 1
    end



  end
}
