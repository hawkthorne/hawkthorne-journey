local tween = require 'vendor/tween'

return {
  name = 'monkey',
  position_offset = { x = 0, y = 0 },
  height = 29,
  width = 23,
  hp = 1,
  hand_x = 3,
  hand_y = 0,
  antigravity = true,
  damage = 0,
  easeup = 'linear',
  easedown = 'linear',
  height_diff = 40,
  peaceful = true,
  animations = {
    dying = {
      right = {'once', {'1,6'}, 1},
      left = {'once', {'2,6'}, 1},
    },
    default = {
      right = {'loop', {'1,1','1,3','1,2','1,3'}, 0.25},
      left = {'loop', {'2,1','2,3','2,2','2,3'}, 0.25},
    },
    hurt = {
      right = {'loop', {'1,1','1,3','1,2','1,3'}, 0.25},
      left = {'loop', {'2,1','2,3','2,2','2,3'}, 0.25},
    }
  },
  enter = function(enemy)
    enemy.delay = math.random(200)/100
    enemy.start_y = enemy.position.y
    enemy.end_y = enemy.start_y + enemy.props.height_diff
  end,
  update = function(dt, enemy, player)
    if (enemy.position.y < enemy.start_y) then
      enemy.going_down = true
    elseif enemy.position.y > enemy.end_y then
      enemy.going_down = false
    end
    if enemy.going_down then
      enemy.position.y = enemy.position.y + 10*dt
    else
      enemy.position.y = enemy.position.y - 10*dt
    end
  end

}
