local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'
local Sprite = require 'nodes/sprite'
local Dialog = require 'dialog'
local player = require 'player'
local Player = player.factory()

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'qfo',
  isBoss = true,
  die_sound = 'explosion_quiet',
  isBoss = true,
  attackDelay = 1,
  height = 60,
  width = 218,
  damage = 30,
  --attack_bb = true,
  jumpkill = false,
  knockback = 0,
  player_rebound = 400,
  antigravity = true,
  bb_width = 218,
  bb_height = 15,
  chargeUpTime = 0,
  --bb_offset = { x = -40, y = 10},
  --attack_width = 40,
  --attack_offset = { x = -40, y = 10},
  velocity = {x = 20, y = 50},
  hp = 60,
  tokens = 20,
  hand_x = -40,
  hand_y = 70,
  dyingdelay = 2,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    default = {
      right = {'loop', {'1-3,1','1-3,2','1,3'}, .1},
      left = {'loop', {'1-3,1','1-3,2','1,3'}, .1}
    },
    dying = {
      right = {'once', {'2-3,3', '1-3,4','1-3,5','1-3,6','1-3,7','1-3,8','1-3,9'}, 0.1},
      left = {'once', {'2-3,3', '1-3,4','1-3,5','1-3,6','1-3,7','1-3,8','1-3,9'}, 0.1}
    },
    enter = {
      right = {'once', {'1,1'}, 0.25},
      left = {'once', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1,1'}, .1},
      left = {'loop', {'1,1'}, .1}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.directiony = math.random(2) == 1 and 'up' or 'down'
    enemy.state = 'default'
    enemy.hatched = false
    enemy.dropmax = enemy.position.y --336
    enemy.velocity.y = 10
    enemy.last_attack = 0
    Timer.add(.1, function() 
      enemy.maxx = enemy.position.x + 48
      enemy.minx = enemy.position.x - 48
      enemy.maxy = enemy.position.y + 5
      enemy.miny = enemy.position.y - 5
      enemy.hatched = true
     end)
  end,

  die = function( enemy )
    if enemy.quest and Player.quest == enemy.quest then
      enemy.db:set("bosstriggers.qfo", true)
    end
  end,

  draw = function( enemy )
    if enemy.quest and Player.quest ~= enemy.quest then return end
    fonts.set( 'small' )


    local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
    local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
    local bossPic = love.graphics.newImage('images/enemies/bossHud/qfoBoss.png')

    energy:setFilter('nearest', 'nearest')
    bossChevron:setFilter('nearest', 'nearest')
    bossPic:setFilter('nearest', 'nearest')

    x, y = camera.x + window.width - 130 , camera.y + 10

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( bossChevron, x , y )
    love.graphics.draw( bossPic, x + 69, y + 10 )

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf( "QFO", x + 15, y + 15, 52, 'center' )
    love.graphics.printf( "BOSS", x + 15, y + 41, 52, 'center' )

    energy_stencil = function( x, y )
      love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
    end
    local max_hp = 60
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

  spawn_beam = function ( enemy, direction, offset )
    --spawns the alien beam
    local beamPos = enemy.position.x+offset
    if not enemy.dead then
      local node = {
        type = 'sprite',
        name = 'qfoBeam',
        x = beamPos,
        y = enemy.position.y+41,
        width = 30,
        height = 20,
        properties = {sheet = 'images/sprites/valley/qfoBeam.png', 
                      speed = .07, 
                      animation = '1-8,1',
                      width = 40,
                      height = 135,
                      mode = 'once',
                      foreground = true}
      }
      local beam = Sprite.new( node, enemy.collider )
      local level = enemy.containerLevel
      local random = math.random(0,9)
      level:addNode(beam)
      Timer.add(.5, function() 
          if random == 0 then
            enemy.props.spawn_alien_elite(enemy, direction, beamPos)
          elseif random == 1 or random == 2 or random == 3 then
            enemy.props.spawn_alien_ranged(enemy, direction, beamPos)
          elseif random == 4 or random == 5 then
            enemy.props.spawn_alien_heavy(enemy, direction, beamPos)
          else
            enemy.props.spawn_alien(enemy, direction, beamPos)
          end
      end)
    end
  end,
  spawn_alien = function( enemy, direction, beamPos )
    local node = {
      x = beamPos,
      y = enemy.position.y+128,
      type = 'enemy',
      properties = {
          enemytype = 'alien'
      }
    }
    local spawnedAlien = Enemy.new(node, enemy.collider, enemy.type)
    spawnedAlien.velocity.x = math.random(20,50)*direction
    enemy.containerLevel:addNode(spawnedAlien)
  end,

  spawn_alien_elite = function( enemy, direction, beamPos )
    local node = {
      x = beamPos,
      y = enemy.position.y+128,
      type = 'enemy',
      properties = {
          enemytype = 'alien_elite'
      }
    }
    local spawnedAlienElite = Enemy.new(node, enemy.collider, enemy.type)
    spawnedAlienElite.velocity.x = math.random(40,60)*direction
    enemy.containerLevel:addNode(spawnedAlienElite)
  end,
    spawn_alien_ranged = function( enemy, direction, beamPos )
    local node = {
      x = beamPos,
      y = enemy.position.y+128,
      type = 'enemy',
      properties = {
          enemytype = 'alien_ranged'
      }
    }
    local spawnedAlienElite = Enemy.new(node, enemy.collider, enemy.type)
    spawnedAlienElite.velocity.x = math.random(40,60)*direction
    enemy.containerLevel:addNode(spawnedAlienElite)
  end,
    spawn_alien_heavy = function( enemy, direction, beamPos )
    local node = {
      x = beamPos,
      y = enemy.position.y+128,
      type = 'enemy',
      properties = {
          enemytype = 'alien_heavy'
      }
    }
    local spawnedAlienElite = Enemy.new(node, enemy.collider, enemy.type)
    spawnedAlienElite.velocity.x = math.random(40,60)*direction
    enemy.containerLevel:addNode(spawnedAlienElite)
  end,

 --[[ spawn_pilot = function( enemy)
    local node = {
      x = enemy.position.x,
      y = enemy.position.y-25,
      type = 'enemy',
      properties = {
          enemytype = 'alien_pilot'
      }
    }
    local spawnedPilot = Enemy.new(node, enemy.collider, enemy.type)
    enemy.containerLevel:addNode(spawnedPilot)
  end,]]
 spawn_pilot = function( enemy)
    local node = {
      x = enemy.position.x,
      y = enemy.position.y-25,
      type = 'enemy',
      properties = {
          enemytype = 'alien_pilot'
      }
    }
    local spawnedPilot = Enemy.new(node, enemy.collider, enemy.type)
    enemy.containerLevel:addNode(spawnedPilot)
  end,

  update = function( dt, enemy, player, level )

    if enemy.dead then return end

    local direction = player.position.x > enemy.position.x + 40 and -1 or 1
    local offset = math.random(0,200)
    if enemy.hp < enemy.props.hp and Player.quest ~= 'Aliens! - Destroy the QFO!' then
      enemy.hp = enemy.hp + 1
    end

    if not enemy.hatched then
      enemy.state = 'default'
    elseif not enemy.hatched and enemy.position.y >= enemy.dropmax then
      enemy.hatched = true
      enemy.velocity.y = 0
      --Timer.add(2, function() enemy.hatched = true end)
    elseif enemy.hatched then
      --move the qfo up and down ( roughly a figure 8 )
      if enemy.state ~= 'hurt' then enemy.idletime = enemy.idletime + dt end
      if enemy.idletime >= 10 then
        if enemy.velocity.y > 0 then
        sound.playSfx( 'qfo_land' )
        end
        enemy.velocity.x = 0
        enemy.velocity.y = 100
        enemy.directiony = 'down'
        Timer.add(2, function()
          enemy.idletime = 0
        end)
      else
        if enemy.position.x > enemy.maxx then
          enemy.direction = 'left'
        elseif enemy.position.x < enemy.minx then
            enemy.direction = 'right'
        end
        if enemy.position.y > enemy.maxy then
            enemy.directiony = 'down'
          elseif enemy.position.y < enemy.miny then
            enemy.directiony = 'up'
        end

        if enemy.direction == 'left' then
          enemy.velocity.x = 50
        else
          enemy.velocity.x = -50 
        end
        
        if enemy.directiony == 'up' then
          enemy.velocity.y = 40
        else
          enemy.velocity.y = -40
        end

        --deal with enemy attacks
        enemy.last_attack = enemy.last_attack + dt

        local pause = 4
      
        if enemy.hp < 10 then
          pause = 2
        elseif enemy.hp < 50 then
          pause = 3
        end
          

        if enemy.last_attack > pause then
          enemy.props.spawn_beam(enemy, direction, offset)
          enemy.last_attack = 0
        end
      end
    end
  end
}