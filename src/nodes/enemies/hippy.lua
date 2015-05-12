local splat = require 'nodes/splat'

return {
  name = 'hippy',
  die_sound = 'hippy_kill',
  passive_sound = 'peace',
  passive_sound_chance = .2,
  attack_sound = { 'sex', 'drugs'},
  height = 48,
  width = 48,
  bb_width = 30,
  bb_height = 24,
  bb_offset = {x=0, y=12},
  damage = 10,
  hp = 6,
  speed = 10,
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
    
    if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'attack' or enemy.state == 'hurt' then
      -- stay put
      enemy.velocity.x = 0
    else
      local direction = enemy.direction == 'left' and 1 or -1
      enemy.velocity.x =  direction * enemy.props.speed
    end
    if enemy.floor then
      if enemy.position.y < enemy.floor then
        enemy.velocity.y = enemy.props.dropspeed
      end
    end
  end
}
