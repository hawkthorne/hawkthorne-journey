local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'bird',
  height = 32,
  width = 32,
  hand_x = 6,
  hand_y = 35,
  bb_width = 32,
  bb_height = 16,
  bb_offset = {x=0, y=6},
  damage = 10,
  hp = 6,
  jumpkill = false,
  antigravity = true,
  chargeUpTime = 3,
  reviveDelay = 3,
  vulnerabilities = {'stab'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    default = {
      left = {'loop', {'1-4,2'}, 0.25},
      right = {'loop', {'1-4,1'}, 0.25}
    },
    hurt = {
      left = {'once', {'5,2'}, 0.25},
      right = {'once', {'5,1'}, 0.25}
    },
    dying = {
      left = {'once', {'5,2'}, 0.25},
      right = {'once', {'5,1'}, 0.25}
    },
    attack = {
      left = {'loop', {'1-4,2'}, 0.25},
      right = {'loop', {'1-4,1'}, 0.25}
    },
  },
  enter = function( enemy )
    --enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 60
    enemy.minx = enemy.position.x - 60
    local bomb
    local near
  end,

  attackranged = function( enemy )
    local node = {
      type = 'projectile',
      name = 'birdbomb',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 9,
      height = 7,
      properties = {}
    }
    local birdbomb = Projectile.new( node, enemy.collider )
    birdbomb.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(birdbomb)
    --if enemy.currently_held then enemy.currently_held:throw(enemy) end
    enemy:registerHoldable(birdbomb)
    enemy:pickup()
    --disallow any manicorn from picking it up after thrown
    birdbomb.enemyCanPickUp = false

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  update = function( dt, enemy, player, level )
    
    if enemy.state == 'dying' then return end


    if math.abs(player.position.x-enemy.position.x) < 330 and enemy.position.y < player.position.y then

        if enemy.currently_held or bomb == true then
          if near ~= true then
          Timer.add(1, function()
              near = true
            end)
          end
          if math.abs(player.position.x-enemy.position.x) < math.random(60,120) then
            if near == true then
              if enemy.currently_held then
              enemy.currently_held:launch(enemy)
              end
              bomb = false
              near = false
            end
          end
        else
          enemy.props.attackranged(enemy)
          bomb = true
        end

    end
    
    if enemy.currently_held then
      enemy.currently_held.x = enemy.x
    end
        
    if enemy.position.x > enemy.maxx then
      enemy.direction = 'left'
    elseif enemy.position.x < enemy.minx then
      enemy.direction = 'right'
    end

    if enemy.direction == 'left' then
      enemy.velocity.x = 60
    else
      enemy.velocity.x = -60
    end

  end
}