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
  speed = math.random(40,50),
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

  update = function ( dt, enemy, player )
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end
    enemy.last_jump = enemy.last_jump + dt*math.random()
    if enemy.last_jump > 4 then
      enemy.state = 'jump'
      enemy.jumpkill = false
      enemy.last_jump = math.random()
      enemy.velocity.y = -300
      Timer.add(.5, function()
        enemy.state = 'default'
        enemy.jumpkill = true
      end)
    end
    if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'attack' or enemy.state == 'hurt' then
      -- stay put
      enemy.velocity.x = 0
    else
      local direction = enemy.direction == 'left' and 1 or -1
      enemy.velocity.x =  direction * enemy.props.speed
    end
  end,

}