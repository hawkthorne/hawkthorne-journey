local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'alien',
  height = 48,
  width = 29,
  damage = 8,
  jumpkill = true,
  bb_width = 29,
  bb_height = 48,
  bb_offset = {x=0, y=0},
  velocity = {x = 0, y = 0},
  hp = 8,
  vulnerabilities = {'slash'},
  jumpBounce = true,
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'once', {'1,2', '6-7,2'}, 0.1},
      left = {'once', {'1,1', '6-7,1'}, 0.1}
    },
    default = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
    hurt = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'1,1'}, 0.2}
    },
    attack = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.state = 'default'
    enemy.velocity.x = math.random(10,50)
    print('enter')
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction = player.position.x > enemy.position.x and -1 or 1


    if player.position.x > enemy.position.x then 
      enemy.direction = 'right'
      enemy.velocity.x = enemy.velocity.x *direction
    else
      enemy.direction = 'left'
    end

  end
}