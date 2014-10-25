local Enemy = require 'nodes/enemy'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local Sprite = require 'nodes/sprite'
local sound = require 'vendor/TEsound'
local utils = require 'utils'
local game = require 'game'
local collision  = require 'hawk/collision'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
  name = 'benzalkBoss',
  isBoss = true,
  attackDelay = 1,
  height = 90,
  width = 90,
  damage = 40,
  attack_bb = true,
  jumpkill = false,
  guarding = true,
  knockback = 0,
  chargeUpTime = 0.25,
  player_rebound = 200,
  bb_width = 60,
  bb_height = 88,
  bb_offset = { x = 0, y = 0},
  attack_width = 15,
  attack_height = 20,
  attack_offset = { x = 15, y = -2},
  velocity = {x = 1, y = 0},
  hp = 100,
  tokens = 15,
  hand_x = -40,
  hand_y = 70,
  fall_on_death = true,
  speed = 150,
  dyingdelay = 1,
  vulnerabilities = {'epic'},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    jump = {
      right = {'loop', {'1-3,4','2,4'}, 0.25},
      left = {'loop', {'1-3,2','2,2'}, 0.25}
    },
    attack = {
      right = {'once', {'3-5,3','4,3', '3,3'}, 0.2},
      left = {'once', {'3-5,1','4,1', '3,1'}, 0.2}
    },
    default = {
      right = {'loop', {'1-2,3'}, 0.25},
      left = {'loop', {'1-2,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'4,4'}, 0.25},
      left = {'loop', {'4,2'}, 0.25}
    },
    dying = {
      right = {'once', {'5-7,4'}, 0.25},
      left = {'once', {'5-7,2'}, 0.25}
    },

  },

  enter = function( enemy )
    enemy.direction = 'left'
    enemy.state = 'default'
    enemy.jump_speed = {x = -150,
                        y = -650,}
    enemy.fly_speed = 75
    enemy.swoop_distance = 150
    enemy.swoop_ratio = 0.75
    enemy.props.attackFire(enemy)
    enemy.maxx = enemy.position.x - 500

    if not enemy.props.original_pos then
      enemy.props.original_pos = {
        x = enemy.position.x,
        y = enemy.position.y
      }
    end
  end,

  die = function( enemy )
    enemy.velocity.y = enemy.speed
    enemy.db:set("bosstriggers.benzalk", true)
  end,

  draw = function( enemy )
    fonts.set( 'small' )

    love.graphics.setStencil( )

    local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
    local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
    local bossPic = love.graphics.newImage('images/enemies/bossHud/benzalkBoss.png')

    energy:setFilter('nearest', 'nearest')
    bossChevron:setFilter('nearest', 'nearest')
    bossPic:setFilter('nearest', 'nearest')

    x, y = camera.x + window.width - 130 , camera.y + 10

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw( bossChevron, x , y )
    love.graphics.draw( bossPic, x + 69, y + 10 )

    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.printf( "Benzalk", x + 15, y + 15, 52, 'center' )
    love.graphics.printf( "GUARD", x + 15, y + 41, 52, 'center' )

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

  guard = function( enemy )
    enemy.props.guarding = true
    enemy.direction = enemy.props.original_pos.x < enemy.position.x and "left" or "right"
  end,

  recoil = function( enemy )
    enemy.props.recoiling = true
    local direction = enemy.direction == "left" and -1 or 1
    enemy.velocity.x = 200 * direction
    Timer.add(0.10, function()
      enemy.props.recoiling = false
    end)
  end,

  attackFire = function( enemy )
    if enemy.dead or enemy.props.guarding then return end

    enemy.state = 'attack'
    local node = {
      type = 'projectile',
      name = 'benzalkFire',
      x = enemy.position.x + (enemy.width / 2),
      y = enemy.position.y + (enemy.height / 2),
      width = 16,
      height = 16,
      properties = {}
    }

    Timer.add(enemy.props.chargeUpTime, function()
      if enemy.props.guarding then return end
      local benzalkFire = Projectile.new( node, enemy.collider )
      benzalkFire.enemyCanPickUp = true

      enemy.containerLevel:addNode(benzalkFire)
      enemy:registerHoldable(benzalkFire)
      enemy:pickup()
      enemy.currently_held:throw(enemy)

      benzalkFire.enemyCanPickUp = false

      enemy.last_attack = 0

      enemy.props.recoil(enemy)

      Timer.add(0.25, function()
        enemy.state = 'default'
      end)
    end)
  end,

  jump = function ( enemy, player, direction )
    local direction = player.position.x > enemy.position.x + 90 and -1 or 1

    if enemy.props.guarding then
      direction = enemy.props.original_pos.x > enemy.position.x and -1 or 1
    end

    sound.playSfx( 'benzalk_growl' )
    enemy.state = 'jump'
    enemy.last_jump = 0
    enemy.fly_dir = direction
    enemy.launch_y = enemy.position.y
    local p_x = player.position.x - player.character.bbox.x
    local p_y = player.position.y - player.character.bbox.y
    enemy.swoop_distance = math.abs(p_y - enemy.position.y)
    enemy.swoop_ratio = math.abs(p_x - enemy.position.x) / enemy.swoop_distance
    -- experimentally determined max and min swoop_ratio values
    enemy.swoop_ratio = math.min(1.4, math.max(0.7, enemy.swoop_ratio))
  end,

  jumpWind = function ( enemy )
    local level = enemy.containerLevel

    if not enemy.dead then
      --add left jump wind
      local windL = {
        type = 'sprite',
        name = 'jump_wind',
        x = enemy.position.x-5,
        y = enemy.position.y+72,
        width = 30,
        height = 20,
        properties = {sheet = 'images/sprites/castle/jump_wind.png',
                      speed = .07,
                      animation = '1-7,1',
                      width = 30,
                      height = 20,
                      mode = 'once',
                      foreground = false}
      }

      --add right jump wind
      local windR = windL
      windR.x = enemy.position.x + 70
      windR.properties.animation = '1-7,2'

      local jumpL = Sprite.new( windL, enemy.collider )
      local jumpR = Sprite.new( windL, enemy.collider )
      level:addNode(jumpL)
      level:addNode(jumpR)
    end
  end,
  
  floor_pushback = function( enemy )
    local level = enemy.containerLevel
    if not enemy.props.recoiling then
      enemy.velocity.x = 0
    end
    if enemy.state == 'jump' then
      enemy.props.jumping = false
      enemy.props.jumpWind( enemy )
      enemy.state = 'default'

      enemy.camera.tx = camera.x
      enemy.camera.ty = camera.y

      sound.playSfx( 'jump_boom' )

      if level.player.jumping then return end
      enemy.shake = true
      level.trackPlayer = false
      level.player.freeze = true
      Timer.add(0.5, function()
        enemy.props.attackFire(enemy)
        enemy.shake = false
        level.trackPlayer = true
        if level.player and level.player.dead ~= true then
          level.player.freeze = false
        end
      end)
    end
  end,

  hurt = function( enemy )
    if enemy.currently_held then
      enemy.currently_held:die()
    end
  end,

  dyingupdate = function ( dt, enemy )
    enemy.velocity.y = enemy.velocity.y + game.gravity * dt * 0.4
    enemy.position.y = enemy.position.y + enemy.velocity.y * dt
  end,

  update = function( dt, enemy, player )
    local level = enemy.containerLevel
    local shake = 0
    local player_dist= {x = 1, y = 1 }
    local player_dir= {x = 'left', y = 'below' }
    
    --checks where the player is in relation to benzalk
    if player.position.x < enemy.position.x then
       player_dist.x = math.ceil((enemy.position.x - player.position.x))
       player_dir.x = 'left'
    else 
       player_dist.x = math.ceil((player.position.x - enemy.position.x))
       player_dir.x = 'right'
    end

    if player.position.x < 350 then
      enemy.props.guard( enemy )
    else
      enemy.props.guarding = false
    end

    --checks if the player is above benzalk 
    if player.position.y < enemy.position.y-55 then
      player_dir.y = 'above'
    else
      player_dir.y = 'below'
    end
    if enemy.shake and level.trackPlayer == false then
      shake = (math.random() * 4)-2/player_dist.x
      camera:setPosition(enemy.camera.tx + shake, enemy.camera.ty + shake)
    end

    if enemy.dead or enemy.state == 'attack' then return end
    if enemy.state == 'dying' then return end

    if player.position.x > enemy.position.x + 50 then
      enemy.direction = 'right'
    else
      if not enemy.props.guarding then
        enemy.direction = 'left'
      end
    end

    enemy.last_jump = enemy.last_jump + dt
    enemy.last_attack = enemy.last_attack + dt

    local pause = 1.5
    
    if enemy.hp < 20 then
      pause = 0.7
    elseif enemy.hp < 50 then
      pause = 1
    end
    
    --triggers the jump attack or the fire attack
    if enemy.last_jump > 4 and enemy.state ~= 'attack' then
      enemy.props.jump( enemy, player, enemy.direction )
      enemy.velocity.y = enemy.jump_speed.y
      -- swoop ratio used to center on target
      enemy.velocity.x = -( enemy.jump_speed.x * enemy.swoop_ratio ) * enemy.fly_dir
    elseif not enemy.props.guarding and enemy.last_attack > pause and enemy.state ~= 'jump' and enemy.last_jump > 1 and enemy.shake == false then
      local rand = math.random()
      if enemy.hp < 80 and rand > 0.4 then
        enemy.props.attackFire(enemy)
      elseif enemy.hp < 40 and rand > 0.2 then
        enemy.props.attackFire(enemy)
      end
    end
  end
}