local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'mike',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  damage = 20,
  revivedelay = 0.3,
  bb_width = 30,
  hp = 40,
  speed = 105,
  calm_speed = 60,
  jumpkill = false,
  tokens = 12,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    attack = {
      right = {'loop', {'2-4,2'}, 0.25},
      left = {'loop', {'2-4,1'}, 0.25}
    },
    default = {
      right = {'loop', {'2-4,2'}, 0.25},
      left = {'loop', {'2-4,1'}, 0.25}
    },
    hurt = {
      right = {'once', {'7,2'}, 0.5},
      left = {'once', {'7,1'}, 0.5}
    },
    dying = {
      right = {'once', {'7,2'}, 0.5},
      left = {'once', {'7,1'}, 0.5}
    },
    standing = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'1,1'}, 0.2}
    },
    pushattack = {
      right = {'loop', {'5-6,2'}, 0.2},
      left = {'loop', {'5-6,1'}, 0.2}
    },
  },
  pushattack = function (enemy)
    enemy.state = 'pushattack'
    enemy.player_rebound = 650
    Timer.add(1.2, function() 
      if enemy.state ~= 'dying' then
        enemy.state = 'default'
        enemy.player_rebound = 300
        enemy.idletime = 0        
        enemy.maxx = enemy.position.x + 48
        enemy.minx = enemy.position.x - 48
      end
    end)
  end,

  enter = function( enemy )
    enemy.direction = 'left'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction
    local velocity

    if math.abs(enemy.position.x - player.position.x) < 184 then
      enemy.idletime = enemy.idletime + dt
        if enemy.idletime >= 2 then
            enemy.props.pushattack(enemy)
        else
          enemy.state = 'default'
        end

        if math.abs(enemy.position.x - player.position.x) < 2 then
            velocity = 0
        elseif enemy.position.x < player.position.x then
            enemy.direction = 'right'
            velocity = enemy.props.speed
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
            enemy.direction = 'left'
            velocity = enemy.props.speed
        end
    else
      enemy.state = 'standing'
      velocity = 0
    end
    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction


  end
}
