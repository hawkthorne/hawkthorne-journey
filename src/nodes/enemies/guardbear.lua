local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'guardbear',
  attack_sound = 'acorn_growl',
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  damage = 25,
  bb_width = 48,
  bb_height = 48,
  bb_offset = { x = 0, y = 0},
  jumpkill = false,
  hp = 200,
  tokens = 4,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,2'}, 0.25}
    },
    default = {
      right = {'loop', {'2-3,2'}, 0.2},
      left = {'loop', {'2-3,3'}, 0.2}
    },
    rage = {
      right = {'loop', {'2-3,5'}, 0.25},
      left = {'loop', {'2-3,4'}, 0.25}
    },
    pause = {
      right = {'once', {'1,3'}, 0.25},
      left = {'once', {'1,2'}, 0.25}
    }
  },
  enter = function(enemy)
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 12
    enemy.minx = enemy.position.x - 12
  end,

  hurt = function( enemy )
    enemy.state = 'rage'
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction 
    local velocity = 60
    local pause = false

    if player.position.y + player.height > math.abs(enemy.position.y + enemy.props.height + 40) then
      if enemy.direction == 'left' and enemy.position.x > player.position.x then
        enemy.state = 'rage'
      elseif enemy.direction == 'right' and enemy.position.x < player.position.x then
        enemy.state = 'rage'
      end
    else
      enemy.state = 'default'
    end

    if enemy.state == 'rage' then 
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 130
      elseif enemy.position.x > player.position.x then--+ player.width then
        enemy.direction = 'left'
        velocity = 130
      end
    end


      if enemy.position.x > enemy.maxx and enemy.state ~= 'rage' then
        enemy.state = 'pause'
        velocity = 0
        Timer.add(5, function() 
          enemy.direction = 'left'
          enemy.state = 'default'
          velocity = 60
        end)
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'rage'then
        enemy.state = 'pause'
        velocity = 0
        Timer.add(5, function() 
          enemy.direction = 'right'
          enemy.state = 'default'
          velocity = 60
        end)
      end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction

  end
}
