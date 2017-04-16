local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
  name = 'qilin',
  die_sound = 'manicorn_neigh',
  position_offset = { x = 0, y = 0 },
  height = 58,
  width = 72,
  bb_height = 50,
  bb_width = 65,
  bb_offset = {x=0, y=9},
  hp = 25,
  speed = 350,
  vulnerabilities = {'blunt'},
  damage = 30,
  tokens = 10,
  materials = 1,
  materialTypes = { -- p is probability ceiling, with the last being 1
    { item = 'blade', p = 0.1 },
    { item = 'arm', p = 0.3 },
  },
  tokenTypes = { -- p is probability ceiling, with the last being 1
      { item = 'coin', v = 1, p = 0.2 },
      { item = 'health', v = 1, p = 0.4 },
      { item = 'greaterCoin', v = 10, p = 0.7 },
      { item = 'gold', v = 100, p = 1 },
  },
  animations = {
    default = {
      left = {'loop', {'1-2,1'}, 0.2},
      right = {'loop', {'1-2,2'}, 0.2}
    },
    hurt = {
      left = {'loop', {'1-2,1'}, 0.2},
      right = {'loop', {'1-2,2'}, 0.2}
    },
    attack = {
      left = {'loop', {'3-5,1'}, 0.2},
      right = {'loop', {'3-5,2'}, 0.2}
    },
    hurt = {
      left = {'once', {'6,1'}, 0.4},
      right = {'once', {'6,2'}, 0.4}
    },
    dying = {
      left = {'once', {'7-8,1'}, 0.4},
      right = {'once', {'7-8,2'}, 0.4}
    }
  },
  enter = function( enemy )
    enemy.state = 'attack'
  end,
  update = function( dt, enemy, player )
    if enemy.state == 'default' then
      if enemy.position.x > player.position.x then
        enemy.direction = 'left'
      else
        enemy.direction = 'right'
      end
      enemy.velocity.x = 0
      Timer.add(2, function()
        if enemy.state ~= 'dying' then
          enemy.state = 'attack'
          enemy.jumpkill = false
        end
      end)
    end
    if enemy.state == 'attack' then
      if (enemy.direction == 'left' and enemy.position.x < player.position.x and (player.position.x - enemy.position.x + enemy.props.width > 50)) or
        (enemy.direction == 'right' and enemy.position.x > player.position.x and (enemy.position.x - player.position.x + player.width > 50)) then
        enemy.state = 'default'
        enemy.jumpkill = true
      end
      if enemy.direction == 'left' then
        enemy.velocity.x = enemy.props.speed
      else
        enemy.velocity.x = -enemy.props.speed
      end
    end
  end
}
