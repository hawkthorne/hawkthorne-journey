local tween = require 'vendor/tween'

return {
  name = 'monkey',
  position_offset = { x = 0, y = 0 },
  height = 29,
  width = 23,
  hp = 1,
  hand_x = 3,
  hand_y = 0,
  speed = 10,
  antigravity = true,
  damage = 0,
  easeup = 'linear',
  easedown = 'linear',
  height_diff = 40,
  peaceful = true,
  materials = 1,
  materialTypes = { -- p is probability ceiling, with the last being 1
    { item = 'banana', p = 0.1 },
  },
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
      enemy.velocity.y = 0
    end
    local direction = enemy.going_down and 1 or -1
      enemy.velocity.y =  direction * enemy.props.speed
  end

}
