local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Projectile = require 'nodes/projectile'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Quest = require 'quest'

return {
  name = 'ambush_alien_heavy',
  die_sound = 'alien_hurt',
  breakBlock = false,
  height = 48,
  width = 48,
  damage = 8,
  jumpkill = false,
  chargeUpTime = 0,
  range = math.random(200,220),
  bb_width = 32,
  bb_height = 48,
  bb_offset = {x=0, y=0},
  speed = math.random(40,50),
  hp = 12,
  vulnerabilities = {'slash'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'4,1'}, 0.2}
    },
    default = {
      right = {'loop', {'4,2','2,2','3,2'}, 0.2},
      left = {'loop', {'2,1','1,1','3,1','1,1',}, 0.2},
    },
    hurt = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'4,1'}, 0.2}
    },
    standing = {
      right = {'loop', {'4,2'}, 0.2},
      left = {'loop', {'1,1'}, 0.2}
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,

  laserAttack = function( enemy, direction, player )
    local node = {
      type = 'projectile',
      name = 'alien_gatling',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 17,
      height = 5,
      properties = {}
    }
    local laser = Projectile.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(laser)
    laser.burn = true
    laser.velocity.x = 250*direction
    laser.velocity.y = math.random(-10,10)
    laser.position.x = enemy.position.x +15
    laser.position.y = enemy.position.y + 40
    Timer.add(0.1, function()
    end)
  end,
  update = function( dt, enemy, player, level )

    enemy.idletime = enemy.idletime + dt
    enemy.chargeUpTime = enemy.chargeUpTime + dt
    local direction 
    local velocity = enemy.props.speed
      if math.abs(enemy.position.x - player.position.x) < 350 then
        if math.abs(enemy.position.x - player.position.x) < enemy.range then
          if math.abs(enemy.position.x - player.position.x) < 2 then
          velocity = 0
          elseif enemy.position.x < player.position.x then
            enemy.direction = 'right'
            velocity = enemy.props.speed * -1
          else
            enemy.direction = 'left'   
            velocity = enemy.props.speed * -1       
          end
        elseif math.abs(enemy.position.x - player.position.x) == enemy.range then
          velocity = 0
          if enemy.position.x < player.position.x then
            enemy.direction = 'right'
          else
            enemy.direction = 'left'      
          end
        else
          if enemy.position.x < player.position.x then
            enemy.direction = 'right'
            velocity = enemy.props.speed 
          else
            enemy.direction = 'left'   
            velocity = enemy.props.speed     
          end
        end
        --laser attack
        local direction = player.position.x > enemy.position.x and 1 or -1
        if enemy.idletime >= 0.1 and enemy.state ~= 'hurt' then
          if enemy.chargeUpTime >= 1 then
            Timer.add(1, function()
              enemy.idletime = 0
              enemy.chargeUpTime = 0
              end)
          else
          sound.playSfx( 'alien_gatling' )
          enemy.props.laserAttack(enemy, direction, player)
          enemy.idletime = 0
          end
        end
      else  
      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end
      velocity = enemy.props.speed
      end 
      if enemy.velocity.x == 0  then
        if enemy.position.x < player.position.x then
        enemy.direction = 'right'
        else
        enemy.direction = 'left'      
        end
      end
    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction
  end
}