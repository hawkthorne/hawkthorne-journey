local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'giantacorn',
  attack_sound = 'acorn_growl',
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = 4 },
  height = 40,
  width = 40,
  damage = 25,
  bb_width = 28,
  bb_height = 40,
  jumpkill = false,
  hp = 5,
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
      right = {'loop', {'4-5,1'}, 0.25},
      left = {'loop', {'4-5,2'}, 0.25}
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
    local rage 
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 36
    enemy.minx = enemy.position.x - 36
  end,

  die = function(enemy)
    if rage == true then
      enemy.state = 'dyingattack'
    else
      sound.playSfx( "acorn_squeak" )
      enemy.state = 'dying'
    end
  end,

  hurt = function(enemy)
    rage = true
  end,

  update = function(dt, enemy, player, level)

    local rage_velocity = 1
    if rage == true then
      enemy.state = 'rage'
      if math.abs(enemy.position.x - player.position.x) < 2 then
        rage_velocity = 0
      elseif math.abs(enemy.position.x - player.position.x) < 200 then
        rage_velocity = 5
        if enemy.position.x < player.position.x then
          enemy.direction = 'right'
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
          enemy.direction = 'left'
        end
      else 
        enemy.state = 'default'
        rage = false
        rage_velocity = 3
      end 
    else 
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
    end

    
    if enemy.direction == 'left' then
      enemy.velocity.x = 20 * rage_velocity
    else
      enemy.velocity.x = -20 * rage_velocity
    end

  end
}
