local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'manicorn',
  --attack_sound = 'manicorn_running',
  die_sound = 'manicorn_neigh',
  position_offset = { x = 0, y = 0 },
  height = 48,
  width = 48,
  bb_height = 48,
  bb_width = 24,
  damage = 40,
  hp = 13,
  tokens = 10,
  hand_x = 0,
  hand_y = 6,
  jumpkill = false,
  chargeUpTime = 2,
  reviveDelay = 3,
  attackDelay = 1,
  vulnerabilities = {'stab'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'1,2','2,3'}, 0.25},
      left = {'once', {'5,7','4,8'}, 0.25}
    },
    default = {
      left = {'loop', {'5-2,2'}, 0.25},
      right = {'loop', {'1-2,7'}, 0.25}
    },
    hurt = {
      left = {'loop', {'1,2'}, 0.25},
      right = {'loop', {'5,7'}, 0.25}
    },
    attack = {
      left = {'loop', {'2-5,1'}, 0.25},
      right = {'loop', {'4-1,6'}, 0.25}
    },
    attackrainbow_start = {
      left = {'once', {'2,3'}, 1},
      right = {'once', {'4,8'}, 1}
    },
    attackrainbow_charging = {
      left = {'once', {'2,3'}, 1},
      right = {'once', {'4,8'}, 1}
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 24
    enemy.minx = enemy.position.x - 24
  end,
  attack = function( enemy )
    Timer.add(enemy.props.attackDelay, function()
      enemy.props.attackRunning(enemy)
    end)
  end,
  attackRunning = function( enemy )
    enemy.state = 'attack'
    Timer.add(5, function() 
      if enemy.state ~= 'dying' and enemy.state ~= 'dyingattack' then
        enemy.state = 'default'
        enemy.maxx = enemy.position.x + 24
        enemy.minx = enemy.position.x - 24
      end
    end)
  end,
  attackRainbow = function( enemy )
    enemy.state = 'attackrainbow_start'
    local node = {
      type = 'projectile',
      name = 'rainbowbeam',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 24,
      height = 24,
      properties = {}
    }
    local rainbowbeam = Projectile.new( node, enemy.collider )
    rainbowbeam.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(rainbowbeam)
    --if enemy.currently_held then enemy.currently_held:throw(enemy) end
    enemy:registerHoldable(rainbowbeam)
    enemy:pickup()
    --disallow any manicorn from picking it up after thrown
    rainbowbeam.enemyCanPickUp = false

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  update = function( dt, enemy, player, level )
    if enemy.state == 'dying' then return end
    enemy.jumpkill = (enemy.state == 'attackrainbow_charging')

    if enemy.state == 'default' and math.abs(player.position.y-enemy.position.y) < 100
       and math.abs(player.position.x-enemy.position.x) < 300 then
      enemy.idletime = enemy.idletime+dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 2 then
      enemy.props.attackRainbow(enemy)
    end

    local offset = 5 -- distance at which the enemy sees no point in changing direction
    local too_close = false

    if enemy.state == 'attack' or string.find(enemy.state,'attackrainbow') then
      if enemy.state == 'attackrainbow_start' then
        enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        if enemy.currently_held then
          enemy.state = 'attackrainbow_charging'
          enemy.currently_held:launch(enemy)
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
        end
      end

    else
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
    end

    local default_velocity = 20
    local rage_velocity =  150

    local my_velocity = default_velocity

    if enemy.state == 'attack' then
      my_velocity = rage_velocity
    elseif string.find(enemy.state,'attackrainbow') then
      my_velocity = 0
    end

    if enemy.direction == 'left' then
      enemy.velocity.x = my_velocity
    else
      enemy.velocity.x = -my_velocity
    end

  end

}
