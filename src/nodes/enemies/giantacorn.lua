local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'giantacorn',
  attack_sound = 'acorn_growl',
  die_sound = 'acorn_crush',
  --position_offset = { x = 0, y = 4 },
  height = 40,
  width = 40,
  damage = 25,
  bb_width = 26,
  bb_height = 36,
  bb_offset = { x = -1, y = 2},
  jumpkill = false,
  hp = 4,
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
      right = {'loop', {'4-5,1'}, 0.25},
      left = {'loop', {'4-5,2'}, 0.25}
    },
    hurt = {
      right = {'loop', {'9-10,1'}, 0.25},
      left = {'loop', {'9-10,2'}, 0.25}
    },
    attack = {
      right = {'loop', {'9-10,1'}, 0.25},
      left = {'loop', {'9-10,2'}, 0.25}
    },
    rage = {
      right = {'loop', {'9-10,1'}, 0.25},
      left = {'loop', {'9-10,2'}, 0.25}
    },
    dyingattack = {
      right = {'once', {'2,1'}, 0.25},
      left = {'once', {'2,2'}, 0.25}
    }
  },
  enter = function(enemy)
    --enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + math.random(48,60)
    enemy.minx = enemy.position.x - math.random(48,60)
  end,

  rage = function( enemy )
  enemy.state = 'rage'
    Timer.add(5, function() 
      if enemy.state ~= 'dying' and enemy.state ~= 'dyingattack' then
        enemy.state = 'default'
        enemy.maxx = enemy.position.x + math.random(48,60)
        enemy.minx = enemy.position.x - math.random(48,60)
        enemy.props.hp = enemy.hp
        enemy.hp = enemy.props.hp
      end
    end)
  end,

  attack = function(enemy)
    enemy.props.rage(enemy)
  end,

  die = function(enemy)
    if enemy.state == 'rage' then
      enemy.state = 'dyingattack'
    else
      sound.playSfx( "acorn_squeak" )
      enemy.state = 'dying'
    end
  end,

  update = function(dt, enemy, player, level)
    if enemy.state == 'dyingattack' then return end

    local rage_velocity = 0.7
    local velocity = math.random(50,60)

    if enemy.hp < enemy.props.hp then 
        enemy.props.rage(enemy)
    end

    if enemy.state == 'rage' then
      rage_velocity = 2
    end

    if enemy.state == 'rage' then
      if enemy.position.x < player.position.x then
        enemy.direction = 'right'
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
      end
    else
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
    end
    
    if enemy.direction == 'left' then
      enemy.velocity.x = velocity * rage_velocity
    else
      enemy.velocity.x = -velocity * rage_velocity
    end

  end

}
