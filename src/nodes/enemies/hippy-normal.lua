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
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction 
    local velocity

    if math.abs(enemy.position.x - player.position.x) < 200 then
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 40
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = 40
      end

    else 
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
      velocity = 40

    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction

  end
}

