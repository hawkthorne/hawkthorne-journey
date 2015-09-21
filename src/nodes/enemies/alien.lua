local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Quest = require 'quest'

return {
  name = 'alien',
  die_sound = 'alien_hurt',
  height = 48,
  width = 29,
  damage = 8,
  jumpkill = false,
  bb_width = 29,
  bb_height = 48,
  bb_offset = {x=0, y=0},
  speed = math.random(60,70),
  hp = 8,
  vulnerabilities = {'slash'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'loop', {'6,2'}, 0.2},
      left = {'loop', {'6,1'}, 0.2}
    },
    default = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
    hurt = {
      right = {'loop', {'6,2'}, 0.2},
      left = {'loop', {'6,1'}, 0.2}
    },
    standing = {
      right = {'loop', {'4,2'}, 0.2},
      left = {'loop', {'4,1'}, 0.2}
    },
    attack = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
  },

  update = function ( dt, enemy, player )
    local direction 
    local velocity = enemy.props.speed
    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 50 then
        velocity = enemy.props.speed
    else
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = enemy.props.speed
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = enemy.props.speed
      end
    end
    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction
  end

}