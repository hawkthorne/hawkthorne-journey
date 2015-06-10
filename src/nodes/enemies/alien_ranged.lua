local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Projectile = require 'nodes/projectile'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Quest = require 'quest'

return {
  name = 'alien_ranged',
  die_sound = 'alien_hurt',
  height = 48,
  width = 48,
  damage = 25,
  jumpkill = false,
  hand_x = -10,
  hand_y = -24,
  bb_width = 31,
  bb_height = 48,
  range = math.random(180,210),
  --bb_offset = {x=0, y=0},
  velocity = {x = 0, y = 0},
  hp = 14,
  vulnerabilities = {'slash'},
  speed = math.random(60,70),
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
    laser.burn = true
    laser.velocity.x = 310*direction
    laser.position.x = enemy.position.x + 15
    laser.position.y = enemy.position.y + 17
    enemy.idletime = 0

  end,
  update = function( dt, enemy, player, level )

    local direction 
    local velocity = enemy.props.speed
    if player.position.y + player.height < enemy.position.y + enemy.props.height and math.abs(enemy.position.x - player.position.x) < 50 then
        velocity = enemy.props.speed
    else
      enemy.idletime = enemy.idletime + dt
      --laser attack
      local direction = player.position.x > enemy.position.x and 1 or -1
        if enemy.idletime >= 2 and enemy.state ~= 'hurt' then
          enemy.props.laserAttack(enemy, direction, player)
          enemy.idletime = 0
        end
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
        if enemy.velocity.x == 0  then
          if enemy.position.x < player.position.x then
          enemy.direction = 'right'
          else
          enemy.direction = 'left'      
        end
      end
    end
    direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = velocity * direction
  end
}