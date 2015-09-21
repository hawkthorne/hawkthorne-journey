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
  bb_offset = {x=0, y=12},
  damage = 10,
  hp = 6,
  jumpkill = true,
  antigravity = true,
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
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 40
    enemy.minx = enemy.position.x - 40
  end,

  attackranged = function( enemy, direction )
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
    --cloudbomb.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(cloudbomb)
    --cloudbomb.position_offset = { x = 15, y = -20 }
    cloudbomb.position.x = enemy.position.x +24
    cloudbomb.position.y = enemy.position.y + 24
    cloudbomb.velocity.x = math.random(500)*direction
    cloudbomb.velocity.y = math.random(-200,-400)

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,

  update = function( dt, enemy, player, level )

  
    if enemy.state == 'dying' then return end

    local direction = player.position.x > enemy.position.x and 1 or -1
    local velocity

    if enemy.state == 'default' and math.abs(player.position.y-enemy.position.y) < 200
       and math.abs(player.position.x-enemy.position.x) < 230 then
      enemy.idletime = enemy.idletime+dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 2.5 and enemy.state ~= 'attackranged' then
      enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
      
      if math.random(1,3) == 1 then
        sound.playSfx( 'peace' )
      elseif math.random(1,3) == 2 then
        sound.playSfx( 'drugs' )
      else
        sound.playSfx( 'sex' )
      end

      sound.playSfx( 'throw' )
      enemy.props.attackranged(enemy, direction)
      enemy.props.attackranged(enemy, direction)
      enemy.props.attackranged(enemy, direction)
      enemy.state = 'attackranged'
    end

    if enemy.state == 'attackranged' then
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
    else
      if enemy.position.x > enemy.maxx then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx then
        enemy.direction = 'right'
      end
    end

    if enemy.state ~= 'default' then
      velocity = 0
    else
      velocity = 75
    end

    if enemy.direction == 'left' then
      enemy.velocity.x = velocity
    else
      enemy.velocity.x = -velocity
    end
  end

}
