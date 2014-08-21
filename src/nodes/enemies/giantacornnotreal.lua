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
  bb_width = 26,
  bb_height = 36,
  bb_offset = { x = -1, y = 2},
  jumpkill = false,
  hp = 59999999,
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
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 36
    enemy.minx = enemy.position.x - 36
  end,

  hurt = function( enemy )
    enemy.state = 'rage'
  end,

  die = function(enemy)
    if enemy.state == 'rage' then
      enemy.state = 'dyingattack'
      sound.playSfx( "acorn_squeak" )
    else
      sound.playSfx( "acorn_squeak" )
      enemy.state = 'dying'
    end
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction 
    local velocity

    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 50 then
      if enemy.hp < enemy.props.hp then 
      enemy.state = 'rage'
      velocity = 130
      else
      enemy.state = 'default'
      velocity = 50
      end


    elseif enemy.hp < enemy.props.hp and math.abs(enemy.position.x - player.position.x) < 250 then
      enemy.state = 'rage'
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = 130
      elseif enemy.position.x > player.position.x then--+ player.width then
        enemy.direction = 'left'
        velocity = 130
      end

    else 
      enemy.state = 'default'
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end
      velocity = math.random(45,55)

    end

    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction

  end
}
