local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'
local dialog = require 'dialog'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'laserlotusBoss',
  attackDelay = 1,
  height = 48,
  width = 48,
  damage = 17,
  attack_bb = true,
  jumpkill = false,
  knockback = 0,
  bb_width = 48,
  bb_height = 48,
  --bb_offset = { x = -40, y = 10},
  --attack_width = 40,
  --attack_offset = { x = -40, y = 10},
  --velocity = {x = 0, y = 1},
  hp = 100,
  tokens = 15,
  --hand_x = -40,
  --hand_y = 70,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    attack = {
      right = {'loop', {'4,1','5,1','4,1','6,1'}, 0.25},
      left = {'loop', {'8,2','7,2','8,2','6,2'}, 0.25},
    },
    default = {
      right = {'loop', {'4,1','5,1','4,1','6,1'}, 0.25},
      left = {'loop', {'8,2','7,2','8,2','6,2'}, 0.25},
    },
    enter = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'11,2'}, 0.25}
    },
    hurt = {
      right = {'once', {'10,1'}, 0.4},
      left = {'once', {'2,2'}, 0.4}
    },
    castlaser = {
      right = {'loop', {'7-9,1', '8,1'}, 0.25},
      left = {'loop', {'5,2','4,2','3,2','4,2'}, 0.25}
    },
  },

  enter = function( enemy )
    enemy.direction = 'right'
    enemy.state = 'enter'
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
    love.graphics.printf( "LASER", x + 15, y + 15, 52, 'center' )
    love.graphics.printf( "LOTUS", x + 15, y + 41, 52, 'center' )

    energy_stencil = function( x, y )
      love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
    end
    love.graphics.setStencil(energy_stencil, x, y)
    local max_hp = 50
    local rate = 110/max_hp
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

  castlaser = function( enemy, direction, player )
    local node = {
      type = 'projectile',
      name = 'laser',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 18,
      height = 16,
      properties = {}
    }
    local laser = Projectile.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(laser)
    level:addNode(laser)
    level:addNode(laser)
    if enemy.hp < 20 then
    laser.velocity.x = 220*direction
    else
    laser.velocity.x = 200*direction
    end
    laser.velocity.y = math.random(-25,25)
    laser.position.x = enemy.position.x - (math.random(-20,20))
    laser.position.y = enemy.position.y + (math.random(5,20))
    enemy.idletime = 0
  end,

  jump = function ( enemy )
    enemy.last_jump = 0
    enemy.velocity.y = -math.random(370,450)
  end,

  die = function ( enemy, level )
  enemy.containerLevel:saveRemovedNode(enemy)
  local player = require 'player'

  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end
    if enemy.state == 'enter' then
      enemy.state = 'default'
    end
    
    local velocity
    local direction = player.position.x > enemy.position.x and 1 or -1

    enemy.idletime = enemy.idletime+dt
    enemy.last_jump = enemy.last_jump + dt
    
    if enemy.state == 'default' and math.abs(player.position.x-enemy.position.x) < 100 and enemy.state ~= 'castlaser' then
      if enemy.hp < 70 then
      velocity = 130
      else
      velocity = 100
      end
    else 
      enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
      if enemy.hp < 70 then
      velocity = 130
      else
      velocity = 100
      end
    end
    
    if enemy.hp <= 50 and player.quest == 'To Slay An Acorn - Search for the Weapon in the mines' then
    player.freeze = true
    player.quest = 'Return to Tilda'
      script = {
        'The laser wielding man vanishes as you strike the final blow...maybe Tilda has an idea of what to do next.',
      }
      dialogue = dialog.create(script)
      dialogue:open(function() 
      dialogue.finished = true 
      player.freeze = false
      end)
    end

    --periodic jumps
    if enemy.last_jump > 2 and enemy.state == 'default' and enemy.state ~= 'castlaser' then
      enemy.props.jump(enemy)
    end
    --laser attack
    if enemy.idletime >= 4 and enemy.state ~= 'castlaser' and enemy.state == 'default' then
      enemy.state = 'castlaser'
      if enemy.hp < 20 then
      Timer.add(0.5, function()
            local direction = player.position.x > enemy.position.x and 1 or -1
            --I tried using loops, but I suck at it so here is ugly code in all its glory, sorry guys
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
          end)      
      else
      Timer.add(0.5, function()
            local direction = player.position.x > enemy.position.x and 1 or -1
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
            enemy.props.castlaser(enemy, direction, player)
          end)   
    end
  end

      if enemy.state == 'castlaser' then
        enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        velocity = 0
          Timer.add(2, function()
              enemy.state = 'default'
          end)
    end
    --when the enemy hits a wall
    if enemy.state == 'default' and enemy.velocity.x == 0 then
      if enemy.direction == 'left' then
      enemy.direction = 'right'
      else
      enemy.direction = 'left'
      end
    end

    if enemy.direction == 'left' then
      enemy.velocity.x = velocity
    else
      enemy.velocity.x = -velocity
    end
  end

}