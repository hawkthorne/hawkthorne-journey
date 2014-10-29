local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
  name = 'benzalk',
  bb_offset = { x = 0, y = 5 },
  height = 90,
  width = 90,
  bb_height = 77,
  bb_width = 45,
  damage = 20,
  hp = 5,
  tokens = 15,
  hand_x = 0,
  hand_y = 6,
  speed = 20,
  jumpkill = false,
  fall_on_death = true,
  dying_delay = 0,
  vulnerabilities = {'blunt'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.5 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    dying = {
      left = {'once', {'4-7,3'}, 0.25},
      right = {'once', {'4-7,4'}, 0.25}
    },
    default = {
      left = {'loop', {'1-2,1'}, 0.25},
      right = {'loop', {'1-2,2'}, 0.25}
    },
    hurt = {
      left = {'loop', {'4,3'}, 0.25},
      right = {'loop', {'3,3'}, 0.25}
    },
    attack = {
      left = {'loop', {'5,1'}, 0.25},
      right = {'loop', {'5,2'}, 0.25}
    },
    attack_charging = {
      left = {'once', {'3-4,1'}, 1},
      right = {'once', {'3-4,2'}, 1}
    },
    jump_start = {
      left = {'once', {'1,3'}, 1},
      right = {'once', {'1,4'}, 1}
    },
    jumping = {
      left = {'once', {'2-3,3'}, 0.25},
      right = {'once', {'2-3,4'}, 0.25}
    },
  },
  enter = function( enemy )
    -- Possibly add dialogue code here
  end,
  jump = function( enemy )

  end,
  attack = function( enemy )
    -- enemy.state = 'attackrainbow_start'
    -- local node = {
      -- type = 'projectile',
      -- name = 'rainbowbeam',
      -- x = enemy.position.x,
      -- y = enemy.position.y,
      -- width = 24,
      -- height = 24,
      -- properties = {}
    -- }
    -- local rainbowbeam = Projectile.new( node, enemy.collider )
    -- rainbowbeam.enemyCanPickUp = true
    -- local level = enemy.containerLevel
    -- level:addNode(rainbowbeam)
    -- if enemy.currently_held then enemy.currently_held:throw(enemy) end
    -- enemy:registerHoldable(rainbowbeam)
    -- enemy:pickup()
    -- disallow any manicorn from picking it up after thrown
    -- rainbowbeam.enemyCanPickUp = false

  end,
  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,
  die = function ( enemy )
    enemy.velocity.y = enemy.speed
  end,
  update = function( dt, enemy, player, level )
    if enemy.state == 'dying' then return end
    
  end

}
