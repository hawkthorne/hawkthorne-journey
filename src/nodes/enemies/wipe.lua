local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'wipe',
  position_offset = { x = 0, y = 0 },
  height = 24,
  width = 24,
  damage = 20,
  hp = 3,
  tokens = 1,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'5,4'}, 0.25},
      left = {'once', {'5,3'}, 0.25}
    },
    default = {
      right = {'loop', {'2-4,4'}, 0.25},
      left = {'loop', {'2-4,3'}, 0.25}
    },
    hurt = {
      right = {'loop', {'2-4,4'}, 0.25},
      left = {'loop', {'2-4,3'}, 0.25}
    },
    enter = {
      right = {'once', {'4,2'}, 0.25},
      left = {'once', {'4,1'}, 0.25}
    },
    flying = {
      right = {'once', {'3,2'}, 0.25},
      left = {'once', {'3,1'}, 0.25}
    },
    attack = {
      right = {'loop', {'3,4'}, 0.25},
      left = {'loop', {'3,3'}, 0.25}
    }
  },

  enter = function(enemy)
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
  end,

  update = function( dt, enemy, player, level )
    if enemy.deadthen then return end
    
    local direction = player.position.x > enemy.position.x and -1 or 1

    if enemy.velocity.y > 1 then
      enemy.state = 'flying'
      enemy.velocity.y = 10
    elseif math.abs(enemy.velocity.y) < 1 then
      enemy.state = 'default'
      enemy.velocity.y = 0
      enemy.velocity.x = 45 * direction
    end
 
    if enemy.position.x < player.position.x then
      enemy.direction = 'right'
    elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
      enemy.direction = 'left'
    end
  end
}
