local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'cat',
  die_sound = 'meow',
  position_offset = { x = 0, y = 0 },
  height = 20,
  width = 40,
  hp = 1,
  bb_height = 20,
  bb_width = 32,
  bb_offset = {x=3, y=0},
  hand_x = 0,
  hand_y = 6,
  damage = 0,
  peaceful = true,
  animations = {
    dying = {
      right = {'once', {'1,4'}, 0.25},
      left = {'once', {'2,4'}, 0.25},
    },
    default = {
      right = {'loop', {'1,2-3'}, 0.25},
      left = {'loop', {'2,2-3'}, 0.25},
    },
    hurt = {
      right = {'loop', {'1,2-3'}, 0.25},
      left = {'loop', {'2,2-3'}, 0.25},
    }
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 200
    enemy.minx = enemy.position.x - 200
    enemy.velocity.x = enemy.direction=='left' and 20 or -20
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > enemy.maxx then 
      enemy.direction = 'left'
      enemy.velocity.x = 20
    elseif enemy.position.x < enemy.minx then 
      enemy.direction = 'right'
      enemy.velocity.x = -20
    end
  end,
}
