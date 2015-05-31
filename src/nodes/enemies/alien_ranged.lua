local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Projectile = require 'nodes/projectile'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local player = require 'player'
local Player = player.factory()
local Quest = require 'quest'

return {
  name = 'alien_ranged',
  height = 48,
  width = 48,
  damage = 25,
  jumpkill = false,
  hand_x = -10,
  hand_y = -24,
  bb_width = 31,
  bb_height = 48,
  --bb_offset = {x=0, y=0},
  velocity = {x = 0, y = 0},
  hp = 10,
  vulnerabilities = {'slash'},
  speed = math.random(80,90),
  tokens = 6,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'loop', {'6,2'}, 0.2},
      left = {'loop', {'6,1'}, 0.2}
    },
    default = {
      right = {'loop', {'1,2','5,2','2,2'}, 0.2},
      left = {'loop', {'1,1','5,1','2,1'}, 0.2}
    },
    hurt = {
      right = {'loop', {'4,2'}, 0.2},
      left = {'loop', {'4,1'}, 0.2}
    },
    standing = {
      right = {'loop', {'3,2'}, 0.2},
      left = {'loop', {'3,1'}, 0.2}
    },
    attack = {
      right = {'loop', {'1,2','5,2','2,2'}, 0.2},
      left = {'loop', {'1,1','5,1','2,1'}, 0.2}
    },
  },

  laserAttack = function( enemy, direction, player )
    local node = {
      type = 'projectile',
      name = 'alien_laser',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 17,
      height = 5,
      properties = {}
    }
    local laser = Projectile.new( node, enemy.collider )
    local level = enemy.containerLevel
    level:addNode(laser)
    sound.playSfx( 'alien_laser' )
    laser.velocity.x = 310*direction
    laser.position.x = enemy.position.x + 15
    laser.position.y = enemy.position.y + 17
    enemy.idletime = 0

  end,
  update = function( dt, enemy, player, level )
    if enemy.quest and Player.quest ~= enemy.quest then
      enemy:die()
    end
    local direction 
    local velocity = enemy.props.speed
    if enemy.quest then
      if math.abs(enemy.position.x - player.position.x) < 350 then
        enemy.state = 'default'
        enemy.idletime = enemy.idletime + dt
        --laser attack
        local direction = player.position.x > enemy.position.x and 1 or -1
        if enemy.idletime >= 2 then
          enemy.props.laserAttack(enemy, direction, player)
          enemy.idletime = 0
        end
        if math.abs(enemy.position.x - player.position.x) < 2 then
           velocity = 0
        elseif enemy.position.x < player.position.x then
            enemy.direction = 'right'
            velocity = enemy.props.speed
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
            enemy.direction = 'left'
            velocity = enemy.props.speed
        end
      else  
      enemy.state = 'standing'
      velocity = 0
      end 
    else
    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 50 then
        velocity = enemy.props.speed
    else
      enemy.idletime = enemy.idletime + dt
      --laser attack
      local direction = player.position.x > enemy.position.x and 1 or -1
        if enemy.idletime >= 2 then
          enemy.props.laserAttack(enemy, direction, player)
          enemy.idletime = 0
        end
      if math.abs(enemy.position.x - player.position.x) < 2 then
        velocity = 0
      elseif enemy.position.x < player.position.x then
        enemy.direction = 'right'
        velocity = enemy.props.speed
      elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
        enemy.direction = 'left'
        velocity = enemy.props.speed
      end
    end
  end
    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction
  end
}