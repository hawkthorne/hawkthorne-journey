local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'goat',
  die_sound = 'goat',
  passive_sound = 'goat',
  passive_sound_chance = .2,
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  hp = 1,
  bb_height = 48,
  bb_width = 48,
  bb_offset = {x=0, y=0},
  hand_x = 0,
  hand_y = 6,
  speed = 20,
  damage = 0,
  peaceful = true,
  animations = {
    default = {
      right = {'loop', {'1-4,2'}, 0.25},
      left = {'loop', {'1-4,1'}, 0.25},
    },
    dying = {
      right = {'loop', {'5,2'}, 0.25},
      left = {'loop', {'5,1'}, 0.25},
    },
    hurt = {
      right = {'loop', {'5,2'}, 0.25},
      left = {'loop', {'5,1'}, 0.25},
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + math.random(48,60)
    enemy.minx = enemy.position.x - math.random(48,60)
    enemy.velocity.x = enemy.direction=='left' and math.random(15,20) or math.random(-15,-20)
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > enemy.maxx then 
      enemy.direction = 'left'
      enemy.velocity.x = enemy.props.speed
    elseif enemy.position.x < enemy.minx then 
      enemy.direction = 'right'
      enemy.velocity.x = -enemy.props.speed
    end
  end,
}
