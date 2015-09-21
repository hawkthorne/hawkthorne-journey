local tween = require 'vendor/tween'

return {
  name = 'fish_horizontal',
  die_sound = 'acorn_squeak',
  height = 24,
  width = 24,
  position_offset = { x = 0, y = 0 },
  bb_width = 20,
  bb_height = 12,
  bb_offset = {x=0, y=2},
  damage = 10,
  hp = 4,
  jumpkill = false,
  antigravity = true,
  easeup = 'outQuad',
  easedown = 'inQuad',
  movetime = 1,
  dyingdelay = 2, 
  animations = {
    dying = {
      right = {'once', {'6,1'}, 1},
      left = {'once', {'3,1'}, 1}
    },
    default = {
      right = {'loop', {'4-5,1'}, 0.3},
      left = {'loop', {'1-2,1'}, 0.3}
    },
    hurt = {
      right = {'loop', {'4-5,1'}, 0.3},
      left = {'loop', {'1-2,1'}, 0.3}
      }
  },

  enter = function(enemy)
    enemy.direction = 'left' 
    enemy.maxx = enemy.position.x + 108
    enemy.minx = enemy.position.x - 108
  end,

  update = function(dt, enemy, player)
    if enemy.position.x > enemy.maxx then
      enemy.direction = 'left'
    elseif enemy.position.x < enemy.minx then
      enemy.direction = 'right'
    end
    
    
    if enemy.direction == 'left' then
      enemy.velocity.x = 35 
    else
      enemy.velocity.x = -35 
    end
  end
}
