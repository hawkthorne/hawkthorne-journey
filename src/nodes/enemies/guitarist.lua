local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'guitarist',
  die_sound = 'trombone_temp',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  damage = 30,
  revivedelay = 0.3,
  bb_width = 30,
  vulnerabilities = {'stab'},
  hp = 16,
  tokens = 7,
  velocity = { x = 35, y = 0},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'loop', {'5-8,2'}, 0.25},
      left = {'loop', {'1-4,2'}, 0.25}
    },
    default = {
      right = {'loop', {'5-8,2'}, 0.2},
      left = {'loop', {'1-4,2'}, 0.2}
    },
    hurt = {
      right = {'loop', {'5-8,2'}, 0.2},
      left = {'loop', {'1-4,2'}, 0.2}
    },
    dying = {
      right = {'loop', {'5-8,2'}, 0.2},
      left = {'loop', {'1-4,2'}, 0.2}
    },
    attack = {
      right = {'loop', {'5-8,2'}, 0.2},
      left = {'loop', {'1-4,2'}, 0.2}
    },
    pushattack = {
      right = {'loop', {'5-7,3'}, 0.2},
      left = {'loop', {'2-4,3'}, 0.2}
    }
  },
  pushattack = function (enemy)
    enemy.state = 'pushattack'
    enemy.jumpkill = false
    enemy.player_rebound = 850
    Timer.add(1.2, function() 
      if enemy.state ~= 'dying' then
        enemy.state = 'default'
        enemy.jumpkill = true
        enemy.player_rebound = 300
        enemy.maxx = enemy.position.x + 48
        enemy.minx = enemy.position.x - 48
      end
    end)
  end,

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
        velocity = 60
      end

    elseif enemy.hp < enemy.props.hp and math.abs(enemy.position.x - player.position.x) < 250 then
      enemy.idletime = enemy.idletime + dt

      if math.abs(enemy.position.x - player.position.x) < 2 then
          velocity = 0
      elseif enemy.position.x < player.position.x then
          enemy.direction = 'right'
          velocity = 105
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
          enemy.direction = 'left'
          velocity = 105
      end

      if enemy.idletime >= 2 then
          enemy.props.pushattack(enemy)
          enemy.idletime = 0
      end

    else
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
          enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
          enemy.direction = 'right'
      end
      velocity = 60 

    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction


  end
}
