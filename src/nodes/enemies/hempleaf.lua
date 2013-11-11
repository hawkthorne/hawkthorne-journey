local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'hempleaf',
  position_offset = { x = 0, y = 0 },
  height = 7,
  width = 16,
  damage = 18,
  antigravity = true,
  jumpkill = false,
  hp = 2,
  tokens = 0,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'2-3,1'}, 0.25},
      left = {'once', {'2-3,1'}, 0.25}
    },
    default = {
      right = {'loop', {'1,1'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1,1'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    attack = {
      right = {'loop', {'1,1'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.maxx = enemy.position.x + 220
    enemy.minx = enemy.position.x - 220
    enemy.maxy = enemy.position.y + 220
    enemy.miny = enemy.position.y - 220
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    if enemy.state == 'attack' then
      enemy:die()
    end

    if enemy.position.x > enemy.maxx then
      enemy:die()
    elseif enemy.position.x < enemy.minx then
      enemy:die()
    end

    if enemy.position.y > enemy.maxy then
      enemy:die()
    elseif enemy.position.y < enemy.miny then
      enemy:die()
    end
    
    if math.abs(enemy.velocity.y) < 1 then
      enemy:die()
    end

    local angle = math.atan2(((player.position.y+24) - enemy.position.y), (player.position.x+10 - enemy.position.x))
    local dx = 200 * math.cos(angle)
    local dy = 100 * math.sin(angle)

    enemy.position.x = enemy.position.x + (dx * dt)
    enemy.position.y = enemy.position.y + (dy * dt)
  end
}
