local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'squirrel',
  --attack_sound = 'manicorn_running',
  die_sound = 'manicorn_neigh',
  position_offset = { x = 0, y = 0 },
  height = 30,
  width = 44,
  bb_height = 30,
  bb_width = 20,
  damage = 25,
  hp = 13,
  tokens = 10,
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
      right = {'once', {'1,2'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    running = {
      left = {'loop', {'2-4,1'}, 0.2},
      right = {'loop', {'2-4,2'}, 0.2}
    },
    hurt = {
      left = {'loop', {'1,1'}, 0.25},
      right = {'loop', {'1,2'}, 0.25}
    },
    attack = {
      left = {'loop', {'1,1','5,1','6,1'}, 0.25},
      right = {'loop', {'1,2','5,2','6,2'}, 0.25}
    },
    attackacorn_start = {
      left = {'once', {'5,1','6,1','1,1'}, .25},
      right = {'once', {'5,2','6,2','1,2'}, .25}
    },
    attackacorn_charging = {
      left = {'once', {'5,1','6,1','1,1'}, .25},
      right = {'once', {'5,2','6,2','1,2'}, .25}
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
  end,

  attackranged = function( enemy )
    enemy.state = 'attackranged'
    local node = {
      type = 'projectile',
      name = 'cloudbomb',
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
    --disallow any manicorn from picking it up after thrown
    cloudbomb.enemyCanPickUp = false

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  update = function( dt, enemy, player, level )
    if enemy.state == 'dying' then return end


    local velocity

    if enemy.state == 'default' 
       and math.abs(player.position.x-enemy.position.x) < 230 then
      enemy.idletime = enemy.idletime+dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 2 then
      enemy.props.attackranged(enemy)
      enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
    end

    if enemy.state == 'attackranged' then
        if enemy.currently_held then
          enemy.currently_held:launch(enemy)
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
        end

    else
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
    end

  end

}
