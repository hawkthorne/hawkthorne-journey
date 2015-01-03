local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'hippy',
  die_sound = 'hippy_kill',
  attack_sound = {'peace', 'sex', 'drugs'},
  height = 48,
  width = 48,
  hand_x = 6,
  hand_y = 35,
  bb_width = 30,
  bb_height = 30,
  --bb_offset = {x=0, y=12},
  damage = 10,
  hp = 6,
  jumpkill = true,
  antigravity = true,
  chargeUpTime = 1,
  reviveDelay = 3,
  attackDelay = 1,
  vulnerabilities = {'stab'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'9,2'}, 0.25},
      left = {'once', {'9,1'}, 0.25}
    },
    default = {
      left = {'loop', {'5-8,1'}, 0.2},
      right = {'loop', {'5-8,2'}, 0.2}
    },
    hurt = {
      left = {'once', {'1,1'}, 0.25},
      right = {'once', {'1,2'}, 0.25}
    },
    attack = {
      left = {'loop', {'5-8,1'}, 0.2},
      right = {'loop', {'5-8,2'}, 0.2}
    },
    attackranged = {
      left = {'loop', {'2-4,1'}, 0.25},
      right = {'loop', {'2-4,2'}, 0.25}
    },
  },
  enter = function( enemy )
    enemy.direction = 'left' 
  end,

  attackranged = function( enemy )
    enemy.state = 'attackranged'
    local node = {
      type = 'projectile',
      name = 'cloudbomb_horizontal',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 9,
      height = 9,
      properties = {}
    }
    local cloudbomb = Projectile.new( node, enemy.collider )
    cloudbomb.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(cloudbomb)
    --if enemy.currently_held then enemy.currently_held:throw(enemy) end
    enemy:registerHoldable(cloudbomb)
    enemy:pickup()
    --disallow any hippy from picking it up after thrown
    cloudbomb.enemyCanPickUp = false
    cloudbomb.direction = enemy.direction

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  update = function( dt, enemy, player, level )
    if enemy.state == 'dying' then return end


    if enemy.state == 'default' and math.abs(player.position.x-enemy.position.x) < 400 then
      enemy.idletime = enemy.idletime+dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 1 then
      enemy.props.attackranged(enemy)
    end

    if enemy.state == 'attackranged' then
      enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        if enemy.currently_held then
          enemy.currently_held:launch(enemy)
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
        end

    end
  end

}
