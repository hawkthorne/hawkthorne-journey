local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'turkeyBoss',
  attackDelay = 1,
  height = 115,
  width = 215,
  damage = 40,
  attack_bb = true,
  jumpkill = false,
  knockback = 0,
  player_rebound = 1200,
  bb_width = 40,
  bb_height = 95,
  bb_offset = { x = -40, y = 10},
  attack_width = 40,
  attack_offset = { x = -40, y = 10},
  velocity = {x = 0, y = 1},
  hp = 100,
  tokens = 15,
  hand_x = -40,
  hand_y = 70,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    jump = {
      right = {'loop', {'3-4,2'}, 0.25},
      left = {'loop', {'3-4,3'}, 0.25}
    },
    attack = {
      right = {'once', {'2,4'}, 0.2},
      left = {'once', {'3,4'}, 0.2}
    },
    charge = {
      right = {'once', {'1,4'}, 0.8},
      left = {'once', {'4,4'}, 0.8}
    },
    default = {
      right = {'loop', {'1-2,2'}, 0.25},
      left = {'loop', {'1-2,3'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1-2,2'}, 0.25},
      left = {'loop', {'1-2,3'}, 0.25}
    },
    dying = {
      right = {'once', {'1-4,2'}, 0.25},
      left = {'once', {'1-4,3'}, 0.25}
    },
    enter = {
      right = {'once', {'1,5'}, 0.25},
      left = {'once', {'1,5'}, 0.25}
    },
    hatch = {
      right = {'once', {'2-3,5','1-3,1'}, 0.25},
      left = {'once', {'2-3,5','1-3,1'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.state = 'enter'
    enemy.hatched = false
  end,

  die = function( enemy )
    local NodeClass = require('nodes/key')
    local node = {
      type = 'key',
      name = 'white_crystal',
      x = 2592,
      y = 742,
      width = 24,
      height = 24,
      properties = {info = "Congratulations. You have found the White Crystal key. You can now unlock Castle Hawkthorne."},
    }
    local spawnedNode = NodeClass.new(node, enemy.collider)
    local level = gamestate.currentState()
    level:addNode(spawnedNode)
  end,

  draw = function( enemy )
    fonts.set( 'small' )

    love.graphics.setStencil( )

    local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
    local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
    local bossPic = love.graphics.newImage('images/enemies/bossHud/turkeyBoss.png')

    energy:setFilter('nearest', 'nearest')
    bossChevron:setFilter('nearest', 'nearest')
    bossPic:setFilter('nearest', 'nearest')

    x, y = camera.x + window.width - 130 , camera.y + 10

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( bossChevron, x , y )
    love.graphics.draw( bossPic, x + 69, y + 10 )

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf( "TURKEY", x + 15, y + 15, 52, 'center' )
    love.graphics.printf( "BOSS", x + 15, y + 41, 52, 'center' )

    energy_stencil = function( x, y )
      love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
    end
    love.graphics.setStencil(energy_stencil, x, y)
    local max_hp = 100
    local rate = 55/max_hp
    love.graphics.setColor(
      math.min(utils.map(enemy.hp, max_hp, max_hp / 2 + 1, 0, 255 ), 255), -- green to yellow
      math.min(utils.map(enemy.hp, max_hp / 2, 0, 255, 0), 255), -- yellow to red
      0,
      255
    )
    love.graphics.draw(energy, x + ( max_hp - enemy.hp ) * rate, y)

    love.graphics.setStencil( )
    love.graphics.setColor( 255, 255, 255, 255 )
    fonts.revert()
  end,

  attackBasketball = function( enemy )
    local node = {
      type = 'projectile',
      name = 'basketball',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 18,
      height = 16,
      properties = {}
    }
    local basketball = Projectile.new( node, enemy.collider )
    basketball.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(basketball)

    enemy:registerHoldable(basketball)
    enemy:pickup()

    enemy.currently_held:launch(enemy)

    basketball.enemyCanPickUp = false
  end,

  wing_attack = function( enemy, player, delay )
    local state = enemy.state
    if state == 'attack' or state == 'charge' then state = 'default' end
    enemy.state = 'charge'
    Timer.add(0.8, function() enemy.collider:setSolid(enemy.attack_bb) enemy.state = 'attack' end)
    Timer.add(delay, function() enemy.collider:setGhost(enemy.attack_bb) enemy.state = state end)
  end,

  spawn_minion = function( enemy, direction )
    local node = {
      x = enemy.position.x,
      y = enemy.position.y,
      type = 'enemy',
      properties = {
          enemytype = 'turkey'
      }
    }
    local spawnedTurkey = Enemy.new(node, enemy.collider, enemy.type)
    spawnedTurkey.turkeyMax = math.random() > 0.8 and 0 or 1
    spawnedTurkey.velocity.x = math.random(10,100)*direction
    spawnedTurkey.velocity.y = -math.random(200,400)
    spawnedTurkey.last_jump = 1
    enemy.containerLevel:addNode(spawnedTurkey)
  end,

  jump = function ( enemy )
    enemy.state = 'jump'
    enemy.last_jump = 0
    enemy.velocity.y = -math.random(300,800)
  end,

  gobble = function ( enemy )
    if enemy.props.gobble_timer then return end
    sound.playSfx( 'gobble_boss' )
    enemy.props.gobble_timer = Timer.add(6, function() enemy.props.gobble_timer = nil end)
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead or enemy.state == 'attack' then return end

    local direction = player.position.x > enemy.position.x + 40 and -1 or 1

    if enemy.velocity.y > 1 and not enemy.hatched then
      enemy.state = 'enter'
    elseif math.abs(enemy.velocity.y) < 1 and not enemy.hatched then
      enemy.state = 'hatch'
      Timer.add(2, function() enemy.hatched = true end)
    elseif enemy.hatched then

      enemy.last_jump = enemy.last_jump + dt
      enemy.last_attack = enemy.last_attack + dt

      local pause = 1.5
    
      if enemy.hp < 20 then
        pause = 0.7
      elseif enemy.hp < 50 then
        pause = 1
      end
    
      enemy.props.gobble( enemy )
    
      if enemy.last_jump > 2 and enemy.state ~= 'attack' and enemy.state ~= 'charge' then
        enemy.props.jump( enemy )
        Timer.add(0.75, function() enemy.direction = direction == -1 and 'right' or 'left' end)
        
      elseif enemy.last_attack > pause and enemy.state ~= 'jump' then
        local rand = math.random()
        if enemy.hp < 80 and rand > 0.9 then
            enemy.props.spawn_minion(enemy, direction)
        elseif rand > 0.6 then
            enemy.props.wing_attack(enemy, player, enemy.props.attackDelay)
        else
            enemy.props.attackBasketball(enemy)
        end
        enemy.last_attack = -0
      end
      if enemy.velocity.y == 0 and enemy.hatched and enemy.state ~= 'attack' and enemy.state ~= 'charge' then
        enemy.state = 'default'
      end

    end

  end
}