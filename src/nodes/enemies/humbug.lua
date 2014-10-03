local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
  name = 'humbug',
  die_sound = 'acorn_crush',
  position_offset = { x = 0, y = -1 },
  height = 40,
  width = 58,
  bb_width = 44,
  bb_height = 26,
  bb_offset = {x=2, y=7},
  damage = 10,
  hp = 1,
  velocity = { x = 60, y = 30 },
  vulnerabilities = {'blunt'},
  tokens = 1,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  antigravity = true,
  animations = {
    dying = {
      right = {'once', {'7,2'}, 0.4},
      left = {'once',{'7,1'}, 0.4}
    },
    default = {
      right = {'loop', {'1-6, 2'}, 0.1},
      left = {'loop', {'1-6, 1'}, 0.1}
    },
    hurt = {
      right = {'loop', {'1-6, 2'}, 0.1},
      left = {'loop', {'1-6, 1'}, 0.1}
    },
    attack = {
      right = {'loop', {'1-6, 4'}, 0.05},
      left = {'loop', {'1-6, 3'}, 0.05}
    },
  },
  enter = function(enemy)
    enemy.start_y = enemy.position.y
    enemy.end_y = enemy.start_y - (enemy.height*2)
    enemy.start_x = enemy.position.x
  end,
  attack = function(enemy)
    enemy.state = 'attack'
    Timer.add(30, function() 
      if enemy.state ~= 'dying' then
        enemy.state = 'default'
      end
    end)
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end
    
    if enemy.state == 'default' then
      if enemy.position.x ~= enemy.start_x  and (math.abs(enemy.position.x - enemy.start_x) > 3) then
        if enemy.position.x > enemy.start_x then
          enemy.direction = 'left' 
          enemy.velocity.x = enemy.props.velocity.x
        else
          enemy.direction = 'right' 
          enemy.velocity.x = -enemy.props.velocity.x
        end
      end
      if enemy.position.y > enemy.start_y then
        enemy.going_up = true
      end
      if enemy.position.y < enemy.end_y then
        enemy.going_up = false
      end
      if enemy.going_up then
        enemy.velocity.y = -enemy.props.velocity.y
      else
        enemy.velocity.y = enemy.props.velocity.y
      end
    end
    if enemy.state == 'attack' then
      local rage_factor = 4
      if(math.abs(enemy.position.x - player.position.x) > 1) then
        if enemy.direction == 'left' then
          enemy.velocity.x = enemy.props.velocity.x * rage_factor * 0.5
        else
          enemy.velocity.x = -enemy.props.velocity.x * rage_factor * 0.5
        end
      else
        enemy.velocity.x = 0
      end
      if (math.abs(enemy.position.y - player.position.y) > 1) then
        if enemy.position.y < player.position.y then
          enemy.velocity.y = enemy.props.velocity.y * rage_factor
        else
          enemy.velocity.y = -enemy.props.velocity.y * rage_factor
        end
      else
        enemy.velocity.y = 0
      end
    end
  end,
  floor_pushback = function() end,
}
