local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'guardbear',
  attack_sound = 'acorn_growl',
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  damage = 25,
  bb_width = 48,
  bb_height = 48,
  bb_offset = { x = 0, y = 0},
  jumpkill = false,
  hp = 300,
  tokens = 4,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,2'}, 0.25}
    },
    default = {
      right = {'loop', {'2-3,3'}, 0.2},
      left = {'loop', {'2-3,2'}, 0.2}
    },
    rage = {
      right = {'loop', {'2-3,5'}, 0.15},
      left = {'loop', {'2-3,4'}, 0.15}
    },
    pause = {
      right = {'once', {'1,3'}, 0.25},
      left = {'once', {'1,2'}, 0.25}
    }
  },
  enter = function(enemy)
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 120
    enemy.minx = enemy.position.x - 120
  end,

  hurt = function( enemy )
    enemy.state = 'rage'
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

      local direction 
      local velocity = 60

    if math.abs(player.position.y - enemy.position.y) < 10 then
      if enemy.direction == 'left' and enemy.position.x > player.position.x then
        rage = true
      elseif enemy.direction == 'right' and enemy.position.x < player.position.x then
        rage = true
      end
    else
      enemy.state = 'default'
    end

    if rage == true then 
      enemy.state = 'rage'
      if math.abs(enemy.position.x - player.position.x) < 70 and math.abs(player.position.y - enemy.position.y) > 40 then
        velocity = 130
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 130
      elseif enemy.position.x > player.position.x then--+ player.width then
        enemy.direction = 'left'
        velocity = 130
      end
    end

    if enemy.position.x > enemy.maxx and rage ~= true then
        enemy.direction = 'left'
    elseif enemy.position.x < enemy.minx and rage ~= true then
        enemy.direction = 'right'
    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction

  end
}
