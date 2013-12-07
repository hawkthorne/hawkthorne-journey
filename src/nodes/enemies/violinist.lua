local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'violinist',
  die_sound = 'trombone_temp',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  damage = 20,
  revivedelay = 0.3,
  bb_width = 30,
  vulnerabilities = {'stab'},
  hp = 12,
  tokens = 6,
  velocity = { x = 50, y = 0},
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
      right = {'loop', {'5-8,2'}, 0.25},
      left = {'loop', {'1-4,2'}, 0.25}
    },
    hurt = {
      right = {'loop', {'5-8,2'}, 0.25},
      left = {'loop', {'1-4,2'}, 0.25}
    },
    dying = {
      right = {'loop', {'5-8,2'}, 0.25},
      left = {'loop', {'1-4,2'}, 0.25}
    },
    attack = {
      right = {'loop', {'5-8,3'}, 0.1},
      left = {'loop', {'1-4,3'}, 0.1}
    },
    dashattack = {
      right = {'loop', {'3-5,5'}, 0.1},
      left = {'loop', {'3-5,4'}, 0.1}
    }
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,

  dashattack = function(enemy)
    enemy.state = 'dashattack'
    enemy.jumpkill = false
    Timer.add(1, function() 
      if enemy.state ~= 'dying' then
        enemy.state = 'default'
        enemy.jumpkill = true
        enemy.maxx = enemy.position.x + 48
        enemy.minx = enemy.position.x - 48
      end
    end)
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction
    local velocity

    if player.position.y + player.height < enemy.position.y + enemy.props.height and 
      math.abs(enemy.position.x - player.position.x) < 50 and enemy.state ~= 'dashattack' then
      if enemy.hp < enemy.props.hp then 
        velocity = 120
      else
        velocity = 70
      end

    elseif enemy.hp < enemy.props.hp and math.abs(enemy.position.x - player.position.x) < 250 then
      enemy.idletime = enemy.idletime + dt

      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 120
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = 120
      end
      
      if enemy.idletime >= 2 then
        enemy.props.dashattack(enemy)
        enemy.idletime = 0
      end

      direction = enemy.direction == 'left' and 1 or -1
      if enemy.state == 'dashattack' and math.abs(enemy.position.x - player.position.x) > 2 then
        enemy.velocity.x = 220 * direction
      else 
        enemy.velocity.x = velocity * direction
      end

    else
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end
    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = 70 * direction

  end

}
