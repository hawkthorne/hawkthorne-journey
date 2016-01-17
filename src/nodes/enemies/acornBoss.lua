local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'
local app = require 'app'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'acornBoss',
  isBoss = true,
  attack_sound = 'acorn_growl',
  hurt_sound = 'acorn_crush',
  height = 75,
  width = 75,
  damage = 10,
  knockbackDisabled = true,
  jumpkill = false,
  player_rebound = 100,
  bb_width = 70,
  bb_height = 75,
  hp = 100,
  speed = 20,
  abovetime = 0,
  tokens = 40,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    jump = {
      right = {'loop', {'6,1'}, 1},
      left = {'loop', {'6,2'}, 1}
    },
    dying = {
      right = {'once', {'8,1'}, 0.25},
      left = {'once', {'8,2'}, 0.25}
    },
    default = {
      right = {'loop', {'2-5,1'}, 0.25},
      left = {'loop', {'2-5,2'}, 0.25}
    },
    hurt = {
       right = {'loop', {'7,1'}, 0.25},
       left = {'loop', {'7,2'}, 0.25}
    },
    ragehurt = {
      right = {'loop', {'2,3'}, 1},
      left = {'loop', {'5,3'}, 1}
    },
    rageready1 = {
      right = {'loop', {'1-3,6'}, 0.25},
      left = {'loop', {'1-3,7'}, 0.25}
    },
    ragereadyjump1 = {
      right = {'loop', {'4,6'}, 1},
      left = {'loop', {'6,7'}, 1}
    },
    rageready2 = {
      right = {'loop', {'5-7,6'}, 0.25},
      left = {'loop', {'5-7,7'}, 0.25}
    },
    ragereadyjump2 = {
      right = {'loop', {'8,6'}, 1},
      left = {'loop', {'8,7'}, 1}
    },
    rage = {
      right = {'loop', {'2-5,4'}, 0.15},
      left = {'loop', {'2-5,5'}, 0.15}
    },
    ragejump = {
      right = {'loop', {'6,4'}, 1},
      left = {'loop', {'6,5'}, 1}
    },
    rageattack = {
      right = {'loop', {'8,1'}, 1},
      left = {'loop', {'8,2'}, 1}
    },
  },
  enter = function( enemy )
    enemy.direction ='left'
    enemy.speed = enemy.props.speed
    local db = app.gamesaves:active()
    local show = db:get('acornKingVisible', false)
    local dead = db:get("bosstriggers.acorn", false)
    if show ~= true or dead == true then
      enemy.state = 'hidden'
      enemy.collider:setGhost(enemy.bb)
    end

    if show == true then
      for _,door in pairs(enemy.containerLevel.nodes) do
        if door.isDoor and not door.instant then
          door.key = "boss"
          door.open = false
          door.info = "Nope!"
        end
      end
    end
  end,

  die = function( enemy )
    local node = {
      x = enemy.position.x + (enemy.width / 2),
      y = enemy.position.y - (enemy.height / 2),
      type = 'enemy',
      properties = {
        enemytype = 'acorn'
      }
    }
    local acorn = Enemy.new(node, enemy.collider, enemy.type)
    acorn.maxx = enemy.position.x
    acorn.minx = enemy.position.x + enemy.width
    enemy.containerLevel:addNode( acorn )

    enemy.db:set("bosstriggers.acorn", true)
    enemy.db:set('acornKingVisible', false)
  end,

  draw = function( enemy )
    fonts.set( 'small' )

    local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
    local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
    local bossPic = love.graphics.newImage('images/enemies/bossHud/acornBoss.png')
    local bossPicRage = love.graphics.newImage('images/enemies/bossHud/acornBossRage.png')

    energy:setFilter('nearest', 'nearest')
    bossChevron:setFilter('nearest', 'nearest')
    bossPic:setFilter('nearest', 'nearest')

    x, y = camera.x + window.width - 130 , camera.y + 10

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( bossChevron, x , y )
    if enemy.state == 'rage' then
      love.graphics.draw(bossPicRage, x + 69, y + 10 )
    else
      love.graphics.draw(bossPic, x + 69, y + 10 )
    end

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf( "ACORN KING", x + 15, y + 15, 100, 'left', 0, 0.9, 0.9 )
    love.graphics.printf( "BOSS", x + 15, y + 41, 52, 'center'  )

    energy_stencil = function( x, y )
      love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
    end
    local max_hp = 100
    local rate = 55/max_hp
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

  rage = function( enemy, duration )
    if type(enemy.rage) == "string" then return end
    local duration = duration or 8

    enemy.rage = 'rageready1'

    Timer.add(duration / 1.6, function()
      enemy.rage = 'rageready2'
      Timer.add(duration / 2.6, function()
        enemy.rage = 'rage'
        enemy.burn = true
        enemy.damage = enemy.props.damage * 2
        enemy.speed = enemy.props.speed * 5
        enemy.player_rebound = enemy.props.player_rebound + 150
        Timer.add(duration, function()
          enemy.props.calm( enemy )
        end)
      end)
    end)
  end,

  calm = function( enemy )
    if enemy.dead then return end
    enemy.rage = false
    enemy.idletime = 0

    enemy.state = 'default'
    enemy.burn = false
    enemy.damage = enemy.props.damage
    enemy.speed = enemy.props.speed
    enemy.player_rebound = enemy.props.player_rebound
  end,

  hurt = function( enemy )
    if enemy.rage then return end
    enemy.rage = true
    Timer.add(0.5, function()
      enemy.props.rage(enemy, 3)
    end)
  end,

  update = function( dt, enemy, player )
    if enemy.dead then return end

    if enemy.rage and type(enemy.rage) == "string" then
      enemy.state = enemy.rage
    end

    enemy.props.abovetime = enemy.props.abovetime + dt
    if (player.position.y + player.height) < enemy.position.y then
      if enemy.props.abovetime > 2 then
        enemy.props.rage(enemy)
      end
    else
      enemy.props.abovetime = 0
    end

    if enemy.position.x < (player.position.x - (player.width * 2)) then
      enemy.direction = 'right'
    elseif enemy.position.x + enemy.props.width > (player.position.x + (player.width * 2)) then
      enemy.direction = 'left'
    end

    local direction = enemy.direction == 'right' and -1 or 1

    enemy.velocity.x = enemy.speed * direction

    enemy.idletime = enemy.idletime + dt

    if enemy.idletime >= 15 then
      enemy.props.rage(enemy)
    end
  end
}
