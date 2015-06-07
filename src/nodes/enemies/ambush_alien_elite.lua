local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Quest = require 'quest'
local gamestate = require 'vendor/gamestate'

return {
  name = 'ambush_alien_elite',
  die_sound = 'alien_hurt',
  height = 48,
  width = 48,
  damage = 35,
  jumpkill = false,
  --attack_bb = true,
  --attack_width = 10,
  bb_width = 31,
  bb_height = 48,
  bb_offset = {x=5, y=0},
  velocity = {x = 0, y = 0},
  hp = 20,
  vulnerabilities = {'slash'},
  speed = math.random(110,120),
  tokens = 6,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'loop', {'6,2'}, 0.2},
      left = {'loop', {'6,1'}, 0.2}
      },
    hurt = {
      right = {'loop', {'6,2'}, 0.2},
      left = {'loop', {'6,1'}, 0.2}
    },
    standing = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'1,1'}, 0.2}
    },
    default = {
      right = {'loop', {'3-5,2'}, 0.2},
      left = {'loop', {'3-5,1'}, 0.2}
    },
    attack = {
      right = {'loop', {'3-5,2'}, 0.2},
      left = {'loop', {'3-5,1'}, 0.2}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,
  update = function ( dt, enemy, player )
    local direction
    local velocity = enemy.props.speed
    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 30 then
        velocity = enemy.props.speed

    elseif math.abs(enemy.position.x - player.position.x) < 350 then
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = enemy.props.speed
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = enemy.props.speed
      end

    else 
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end
      velocity = enemy.props.speed

    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction
  end
}