local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'trombonist',
  die_sound = 'trombone_temp',
  position_offset = { x = 0, y = 0 },
  height = 39,
  speed = 100,
  width = 58,
  bb_width = 35,
  speed = 100,
  damage = 20,
  hp = 8,
  vulnerabilities = {'stab'},
  tokens = 4,
  velocity = { x = 30, y = 0},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'loop', {'1-4,1'}, 0.25},
      left = {'loop', {'1-4,2'}, 0.25}
    },
    default = {
      right = {'loop', {'4,1', '2-1,1'}, 0.25},
      left = {'loop', {'1,2', '3-4,2'}, 0.25}
    },
    hurt = {
      right = {'loop', {'4,1', '2-1,1'}, 0.25},
      left = {'loop', {'1,2', '3-4,2'}, 0.25}
    },
    dying = {
      right = {'loop', {'4,1', '2-1,1'}, 0.25},
      left = {'loop', {'1,2', '3-4,2'}, 0.25}
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

    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 50 then
      if enemy.hp < enemy.props.hp then 
        velocity = 105
      else
        velocity = 65
      end


    elseif enemy.hp < enemy.props.hp and math.abs(enemy.position.x - player.position.x) < 250 then
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 105
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = 105
      end

    else 
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end
      velocity = 65

    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction

  end
}
