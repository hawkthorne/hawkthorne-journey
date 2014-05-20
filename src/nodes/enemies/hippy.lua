local splat = require 'nodes/splat'

return {
  name = 'hippy',
  die_sound = 'hippy_kill',
  attack_sound = {'peace', 'sex', 'drugs'},
  height = 48,
  width = 48,
  bb_width = 30,
  bb_height = 24,
  bb_offset = {x=0, y=12},
  damage = 10,
  hp = 6,
  vulnerabilities = {'slash'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'6,2'}, 1},
      left = {'once', {'6,1'}, 1}
    },
    default = {
      right = {'loop', {'3-4,2'}, 0.25},
      left = {'loop', {'3-4,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'5,2'}, 0.25},
      left = {'loop', {'5,1'}, 0.25}
    },
    attack = {
      right = {'loop', {'1-2,2'}, 0.25},
      left = {'loop', {'1-2,1'}, 0.25}
    }
  },
  splat = function(enemy)
    local s = splat.new(enemy.position.x, enemy.position.y, enemy.width, enemy.height)
    s:add(enemy.position.x, enemy.position.y, enemy.width, enemy.height)
    return s
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end
    
    if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'attack' then
      -- stay put
    elseif enemy.direction == 'left' then
      enemy.position.x = enemy.position.x - (10 * dt)
    else
      enemy.position.x = enemy.position.x + (10 * dt)
    end
    if enemy.floor then
      if enemy.position.y < enemy.floor then
        enemy.position.y = enemy.position.y + dt * enemy.props.dropspeed
      else
        enemy.position.y = enemy.floor
      end
    end
  end
}
