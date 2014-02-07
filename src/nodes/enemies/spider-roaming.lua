local sound = require 'vendor/TEsound'

--[[ 
  This object represents a spider (sprites courtesy of reddfawks)
  To add one to a map:
    First, add a node with a 'spawn' type
    Then the following properties should be set:
    Property Name       Property Value
      nodeType           enemy
      enemytype          spider
      initialState       dropping
      spawnType          smart/proximity
]]--
return {
  name = 'spider',
  die_sound = 'hippy_kill', -- TODO Need a kill sound
  spawn_sound = 'hippy_enter', -- TODO: Need a 'roar' sound
  height = 48,
  width = 48,
  bb_width = 48,
  bb_height = 48,
  bb_offset = {x=0, y=0},
  damage = 20,
  hp = 12,
  vulnerabilities = {'fire'},
  tokens = 8,
  jumpkill = false,
  speed = 50,
  dropSpeed = 100,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dropping = {
      right = {'once', {'1,1'}, 1},
      left = {'once', {'1,1'}, 1}
    },
    dying = {
      right = {'once', {'4,3'}, 1},
      left = {'once', {'4,2'}, 1}
    },
    hurt = {
      right = {'once', {'3,3'}, 1},
      left = {'once', {'3,2'}, 1}
    },
    default = {
      right = {'loop', {'2-3,3'}, 0.2},
      left = {'loop', {'2-3,2'}, 0.2}
    },
    attack = {
      right = {'once', {'1,3'}, 1},
      left = {'once', {'1,2'}, 1}
    }
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 36
    enemy.minx = enemy.position.x - 36
    enemy.velocity.x = enemy.direction=='left' and 20 or -20
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > enemy.maxx then 
      enemy.direction = 'left'
      enemy.velocity.x = 50
    elseif enemy.position.x < enemy.minx then 
      enemy.direction = 'right'
      enemy.velocity.x = -50
    end
  end,
}
