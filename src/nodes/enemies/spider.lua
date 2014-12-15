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
           spawnType          proximity
]]--
return {
  name = 'spider',
  die_sound = 'acorn_crush', -- TODO Need a kill sound
  spawn_sound = 'hippy_enter', -- TODO: Need a 'roar' sound
  height = 48,
  width = 48,
  bb_width = 36,
  bb_height = 38,
  bb_offset = {x=0, y=5},
  damage = 20,
  hp = 12,
  vulnerabilities = {'fire'},
  tokens = 8,
  jumpkill = false,
  speed = 50,
  dropSpeed = 100,
  materials = 1,
  materialTypes = { -- p is probability ceiling, with the last being 1
    { item = 'eye', p = 0.1 },
    { item = 'arm', p = 0.3 },
  },
  tokenTypes = { -- p is probability ceiling, with the last being 1
    { item = 'coin', v = 1, p = 0.1 },
    { item = 'health', v = 1, p = 0.3 },
    { item = 'greaterCoin', v = 10, p = 0.6 },
    { item = 'gold', v = 100, p = 1 },
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
  floor_pushback = function(enemy)
    -- Only set the state back to default the first time we get a pushback after dropping
    if ( enemy.state == 'dropping' ) then
      -- Once the DropBear hits the floor, transition to the normal walking state
      enemy.state = 'default'
    end

    enemy:moveBoundingBox()
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
    if enemy.state == 'dropping' then
      enemy.velocity.y = enemy.props.dropSpeed
    end
  end
}
