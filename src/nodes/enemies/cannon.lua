local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'cannon',
  height = 13,
  width = 24,
  bb_width = 24,
  bb_height = 13,
  --bb_offset = {x=0, y=12},
  damage = 0,
  hp = 5,
  jumpkill = false,
  antigravity = true,
  chargeUpTime = 0.5,
  vulnerabilities = {'stab'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    default = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    attack = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    attackranged = {
      left = {'loop', {'1-3,1'}, 0.25},
      right = {'loop', {'1-3,1'}, 0.25}
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 40
    enemy.minx = enemy.position.x - 40
  end,

  attackranged = function( enemy )
    local node = {
      type = 'projectile',
      name = 'cannon-bomb',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 9,
      height = 9,
      properties = {}
    }
    local bomb1 = Projectile.new( node, enemy.collider )
    local bomb2 = Projectile.new( node, enemy.collider )
    local bomb3 = Projectile.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(bomb1)
    bomb1.position.y = enemy.position.y - 24
    bomb1.position.x = enemy.position.x + 6
    bomb1.velocity.x = -200
    bomb1.velocity.y = -600

    level:addNode(bomb2)
    bomb2.position.y = enemy.position.y - 24
    bomb2.position.x = enemy.position.x + 6
    bomb2.velocity.y = -750

    level:addNode(bomb3)
    bomb3.position.y = enemy.position.y - 24
    bomb3.position.x = enemy.position.x + 6
    bomb3.velocity.x = 200
    bomb3.velocity.y = -600

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  update = function( dt, enemy, player, level )
    if enemy.state == 'dying' then return end

    local velocity

    if enemy.state == 'default' then --and math.abs(player.position.x-enemy.position.x) < 930 then
      enemy.idletime = enemy.idletime+dt
    else
      enemy.idletime = 0
    end

    if enemy.idletime >= 0.8 and enemy.state ~= 'attackranged' then
      enemy.props.attackranged(enemy)
      enemy.state = 'attackranged'
    end

    if enemy.state == 'attackranged' then
          Timer.add(enemy.chargeUpTime, function()
              enemy.state = 'default'
          end)
    end
  end

}
