local Timer = require 'vendor/timer'

return {
  name = wasabi,
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = 0 },
  height = 36,
  width = 36,
  bb_height = 22,
  bb_width = 36,
  bb_offset = {x=0, y=12},
  damage = 30,
  hp = 8,
  vulnerabilities = {'lightning'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    default = {
      left = {'loop', {'1-4,3'}, 0.25},
      right = {'loop', {'1-4,1'}, 0.25}
    },
    jump = { 
      left = {'once', {'5,4'}, 1},
      right = {'once', {'5,2'}, 1}
    },
    attack = {
      left = {'loop', {'1-2,4'}, 0.1},
      right = {'loop', {'1-2,2'}, 0.1}
    },
    hurt = {
      left = {'loop', {'3,4'}, 0.4},
      right = {'loop', {'3,2'}, 0.4}
    },
    dying = {
      left = {'once', {'4,2'}, 0.4},
      right = {'once', {'4,4'}, 0.4}
    },
  },

  update = function ( dt, enemy, player )
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end
    enemy.last_jump = enemy.last_jump + dt
    if enemy.last_jump > 4 then
      enemy.state = 'jump'
      enemy.jumpkill = false
      enemy.last_jump = 0
      enemy.velocity.y = -500
      Timer.add(.5, function()
        enemy.state = 'default'
        enemy.jumpkill = true
      end)
    end
    if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'attack' then
      -- stay put
    elseif enemy.direction == 'left' then
      enemy.position.x = enemy.position.x - (10 * dt)
    else
      enemy.position.x = enemy.position.x + (10 * dt)
    end
  end
}
