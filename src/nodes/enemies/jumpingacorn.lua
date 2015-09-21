local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'jumpingacorn',
  attack_sound = 'acorn_growl',
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = 4 },
  height = 20,
  bb_width = 12,
  bb_height = 20,
  width = 20,
  damage = 15,
  hp = 1,
  tokens = 2,
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
      right = {'loop', {'7-9,1'}, 0.25},
      left = {'loop', {'7-9,2'}, 0.25}
    },
    jumping = {
      right = {'loop', {'10-11,1'}, 0.25},
      left = {'loop', {'10-11,2'}, 0.25}
    },
    dyingattack = {
      right = {'once', {'2,1'}, 0.25},
      left = {'once', {'2,2'}, 0.25}
    }
  },
  enter = function(enemy)
  enemy.direction = math.random(2) == 1 and 'left' or 'right'
  end,
  
  hurt = function(enemy)
    enemy.velocity.y = 0
  end,

  die = function(enemy)
    enemy.velocity.y = 0
  end,

  update = function(dt, enemy, player, level)
  local direction 

    if math.abs(enemy.position.x - player.position.x) < 100 and enemy.state == 'default' and math.abs(player.position.y - enemy.position.y) < 50 and enemy.hp > 0 then
          if enemy.position.x > player.position.x then
            enemy.direction = 'left'
            direction = 1
          else
            enemy.direction = 'right'
            direction = -1
          end
          enemy.velocity.y = -400
          enemy.velocity.x = math.random(100*direction, 150 * direction) 
          enemy.state = 'jumping'
          Timer.add(0.5, function()
            enemy.velocity.x = 0
          end)                          
          Timer.add(0.5, function()
            enemy.state = 'default'
          end)                  
    end

  end
}

