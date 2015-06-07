local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'squirrel',
  --attack_sound = 'manicorn_running',
  die_sound = 'squirrel_death',
  position_offset = { x = 0, y = 0 },
  height = 30,
  width = 44,
  bb_height = 18,
  bb_width = 24,
  bb_offset = { x = 0, y = 6},
  damage = 0,
  hp = 1,
  tokens = 3,
  hand_x = 0,
  hand_y = 6,
  jumpkill = true,
  chargeUpTime = 1,
  reviveDelay = 1,
  attackDelay = .25,
  vulnerabilities = {'stab'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'7,2'}, 0.25},
      left = {'once', {'7,1'}, 0.25}
    },
    default = {
      right = {'loop', {'2-4,2'}, 0.3},
      left = {'loop', {'2-4,1'}, 0.3}
    },
    hurt = {
      left = {'loop', {'1,1'}, 0.25},
      right = {'loop', {'1,2'}, 0.25}
    },
    attack = {
      left = {'loop', {'1,1','5,1','6,1'}, 0.25},
      right = {'loop', {'1,2','5,2','6,2'}, 0.25}
    },
    attackranged = {
      left = {'once', {'1,1'}, .25},
      right = {'once', {'1,2'}, .25}
    },
    attackthrow = {
      left = {'once', {'5-6,1'}, .25},
      right = {'once', {'5-6,2'}, .25}
    },
  },

  attackranged = function( enemy )
    enemy.state = 'attackranged'
    local node = {
      type = 'projectile',
      name = 'acornBomb',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 15,
      height = 15,
      properties = {}
    }
    local acornBomb = Projectile.new( node, enemy.collider )
    acornBomb.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(acornBomb)
    enemy:registerHoldable(acornBomb)
    enemy:pickup()
    acornBomb.enemyCanPickUp = false
  end,

  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,

  update = function( dt, enemy, player, level )
    if enemy.state == 'default' and math.abs(player.position.x-enemy.position.x) < 350 then
      enemy.idletime = enemy.idletime + dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 1 then
      enemy.props.attackranged(enemy)
    end

    if enemy.state == 'attack' or string.find(enemy.state,'attackranged') then
      if enemy.state == 'attackranged' then
        enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        if enemy.currently_held then
          enemy.state = 'attackthrow'
          enemy.currently_held:launch(enemy)
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
        end
      end
    end
  end
}
