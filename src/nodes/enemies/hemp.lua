local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'hemp',
  die_sound = 'karramba_pop',
  position_offset = { x = 0, y = 0 },
  bb_width = 30,
  bb_height = 36,
  height = 48,
  width = 48,
  damage = 20,
  hp = 1,
  jumpkill = false,
  intangible = true,
  antigravity = true,
  animations = {
    default = {
      right = {'loop', {'1-8,1'}, 0.2},
      left = {'loop', {'1-8,1'}, 0.2}
    },
    dying = {
      right = {'once', {'9-10,1'}, 0.1},
      left = {'once', {'9-10,1'}, 0.1}, 
    },
    hurt = {
      right = {'once', {'9-10,1'}, 0.1},
      left = {'once', {'9-10,1'}, 0.1},    
    },
  },
  enter = function( enemy )
    local descend = false
    local ascend = false
  end,
  update = function( dt, enemy, player )


    if enemy.position.y >= enemy.node.y then
      descend = false
            Timer.add(math.random(1,2), function()
              ascend = true
          end)
    end

    if ascend == true and enemy.position.y >= enemy.node.y-48 then
      enemy.position.y = enemy.position.y - 0.5
    end

    if enemy.position.y <= enemy.node.y-48 then
      ascend = false
      Timer.add(math.random(3,4), function()
              descend = true
          end)
      
    end
    
    if descend == true and enemy.position.y <= enemy.node.y then
      enemy.position.y = enemy.position.y + 0.5
    end


  end
}
