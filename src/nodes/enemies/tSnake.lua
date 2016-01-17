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
  name = 'tSnake',
  isBoss = true,
  die_sound = 'snake_hurt',
  attackDelay = 1,
  height = 144,
  width = 48,
  bb_width = 30,
  bb_height = 144,
  damage = 40,
  --special_damage = {tsnake = 40},
  attack_bb = true,
  jumpkill = false,
  antigravity = true,
  knockback = 0,
  player_rebound = 200,
  attack_width = 10,
  --attack_offset = { x = -40, y = 10},
  velocity = {x = 0, y = -1},
  hp = 70,
  tokens = 15,
  hand_x = 24,
  hand_y = 69,
  dyingdelay = 2,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  diving = false,
  rising = false,
  attackCount = 0,

  animations = {
    default = {
      right = {'loop', {'1-4,2',}, 0.15},
      left = {'loop', {'1-4,1',}, 0.15}
    },
    attack = {
      right = {'once', {'5-7,2'}, 0.15},
      left = {'once', {'5-7,1'}, 0.15}
    },
    dying = {
      right = {'once', {'9-14,2'}, 0.1},
      left = {'once', {'9-14,1'}, 0.1}
    },
    enter = {
      right = {'once', {'1,2'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'once', {'8,2'}, 0.25},
      left = {'once', {'8,1'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.direction = 'left'
    enemy.state = 'default'

    if not enemy.props.original_pos then
      enemy.props.original_pos = {
        x = enemy.position.x,
        y = enemy.position.y
      }
    end
  end,

  die = function( enemy, player )
    local Player = require 'player'
    local player = Player.factory()
    local NodeClass = require('nodes/key')
    local node = {
      type = 'key',
      name = 'ferry',
      x = 1490,
      y = 463,--742,
      width = 24,
      height = 24,
      properties = {},
    }
    local spawnedNode = NodeClass.new(node, enemy.collider)
    local level = gamestate.currentState()
    level:addNode(spawnedNode)
  end,

  draw = function( enemy )
    fonts.set( 'small' )

    local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
    local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
    local bossPic = love.graphics.newImage('images/enemies/bossHud/snakeBoss.png')


    energy:setFilter('nearest', 'nearest')
    bossChevron:setFilter('nearest', 'nearest')
    bossPic:setFilter('nearest', 'nearest')

    x, y = camera.x + window.width - 130 , camera.y + 10

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( bossChevron, x , y )
    love.graphics.draw( bossPic, x + 69, y + 10 )

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf( "TROUSER SNAKE", x + 10, y + 15, 100, 'left' , 0, .8, .8)
    love.graphics.printf( "BOSS", x + 15, y + 41, 52, 'center' )

    energy_stencil = function( x, y )
      love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
    end
    local max_hp = 70
    local rate = 60/max_hp
    love.graphics.setColor(
      math.min(utils.map(enemy.hp, max_hp, max_hp / 2 + 1, 0, 255 ), 255), -- green to yellow
      math.min(utils.map(enemy.hp, max_hp / 2, 0, 255, 0), 255), -- yellow to red
      0,
      255
    )

    local energy_quad = love.graphics.newQuad( -(max_hp - enemy.hp) * rate, 0, 70, 60, energy:getWidth(), energy:getHeight())

    love.graphics.draw(energy, energy_quad, x , y)

    love.graphics.setColor( 255, 255, 255, 255 )
    fonts.revert()
  end,

  attackRainbow = function(enemy)
    enemy.state = 'attack'
    enemy.last_attack = 0
    Timer.add(.5, function()
      enemy.state = 'default'
    end)

  	local node = {
      type = 'projectile',
      name = 'rainbowbeam_tsnake',
      x = enemy.position.x+enemy.attack_offset.x,
      y = enemy.position.y,
      width = 24,
      height = 24,
      properties = {}--velocity = (player.position.x - enemy.position.x), (player.position.y - enemy.position.y) }
    }
    
    local rainbowbeam = Projectile.new( node, enemy.collider )
    rainbowbeam.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(rainbowbeam)
    rainbowbeam.velocity.x = math.random(10,100)--*direction
    enemy:registerHoldable(rainbowbeam)
    enemy:pickup()
    enemy.currently_held:launch(enemy)
    --disallow anything from picking it up after thrown
    rainbowbeam.enemyCanPickUp = false

    local rand = math.random(2,3)
    enemy.props.attackCount = enemy.props.attackCount + 1
    if enemy.props.attackCount >= rand then
      enemy.props.diving = true
      Timer.add(2, function()
        enemy.props.dive(enemy)
      end)
    end
  end,

  dive = function(enemy)
    enemy.props.rising = false
    enemy.props.diving = true
    enemy.velocity.y = 200
    enemy.props.attackCount = 0
  end,

  rise = function(enemy, dt)
    enemy.props.attackCount = 0
    enemy.props.diving = false
    Timer.add(2, function()
      enemy.props.rising = true
      enemy.props.positionChange(enemy, dt)
      enemy.velocity.y = -200
    end)
  end,

  positionChange = function(enemy, dt)
    local pos = {
      x1 = enemy.props.original_pos.x,
      x2 = enemy.props.original_pos.x + 144,
      x3 = enemy.props.original_pos.x + 288
    }
    local i = math.random(1,3)
    enemy.position.x = pos["x" .. i]
  end,

  update = function( dt, enemy, player, level )
    if enemy.dying then enemy.state = 'dying' end

    if player.position.x > enemy.position.x + 24 then
      enemy.direction = 'right'
    else 
      enemy.direction = 'left'
    end

    if enemy.props.diving and enemy.position.y >= enemy.props.original_pos.y + (enemy.height*2) then
      enemy.velocity.y = 0
      enemy.props.rise(enemy, dt)
    end

    if enemy.props.rising and enemy.position.y <= enemy.props.original_pos.y then
      enemy.props.rising = false
      enemy.velocity.y = 0
      enemy.position.y = enemy.props.original_pos.y
    end

    enemy.last_attack = enemy.last_attack + dt
    local pause = 3
    
    if enemy.hp < 20 then
      pause = 1
    elseif enemy.hp < 50 then
      pause = 2.5
    end

    if enemy.last_attack > pause and enemy.position.y == enemy.props.original_pos.y
       and not enemy.props.diving and not enemy.props.diving then
      enemy.props.attackRainbow(enemy)
    end
  end
}