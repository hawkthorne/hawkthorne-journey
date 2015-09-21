local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'alien',
  height = 51,
  width = 51,
  damage = 30,
  jumpkill = true,
  bb_width = 51,
  bb_height = 51,
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

    default = {
      right = {'loop', {'1-4,1'}, 0.2},
      left = {'loop', {'1-4,1'}, 0.2}
    },
    hurt = {
      right = {'loop', {'1-4,1'}, 0.2},
      left = {'loop', {'1-4,1'}, 0.2}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.state = 'default'
    enemy.beamIn = false
    enemy.collider:setGhost(enemy.bb)
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end
    enemy.velocity.x = math.random(100,500)
    enemy.velocity.y = -math.random(100,500)
    local direction = player.position.x > enemy.position.x and -1 or 1
    Timer.add(.7, function() enemy.dead = true end)
    
  end
}