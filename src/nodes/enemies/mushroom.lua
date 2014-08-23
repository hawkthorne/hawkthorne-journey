local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'mushroom',
  die_sound = 'trombone_temp',
  position_offset = { x = 0, y = 0 },
  height = 31,
  width = 32,
  damage = 20,
  vulnerabilities = {'stab'},
  hp = 12,
  tokens = 6,
  velocity = { x = 50, y = 0},
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    default = {
      right = {'loop', {'1-2,1'}, 0.25},
      left = {'loop', {'1-2,2'}, 0.25}
    },
    hurt = {
      right = {'once', {'3,1'}, 0.25},
      left = {'loop', {'3,2'}, 0.25}
    },
    attack = {
      right = {'loop', {'1-2,1'}, 0.25},
      left = {'loop', {'1-2,2'}, 0.25}
    },
    attackranged_start = {
      right = {'once', {'7,1'}, 0.1},
      left = {'once', {'7,2'}, 0.1}
    },
    attackranged_finish = {
      right = {'once', {'8,1'}, 0.1},
      left = {'once', {'8,2'}, 0.1}
    },
  },
  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.maxx = enemy.position.x + 48
    enemy.minx = enemy.position.x - 48
  end,

  attackranged = function(enemy)
    enemy.state = 'attackranged_finish'
    local node = {
      type = 'projectile',
      name = 'goo',
      x = enemy.position.x,
      y = enemy.position.y,
      width = 10,
      height = 8,
      properties = {}
    }
    local shot = Projectile.new( node, enemy.collider )
    shot.enemyCanPickUp = true
    local level = enemy.containerLevel
    level:addNode(shot)
    shot.velocity.x = 200*direction
    enemy.state = 'default'
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end

    local direction = enemy.direction == 'left' and 1 or -1
    local velocity

    if player.position.y + player.height < enemy.position.y + enemy.props.height and 
      math.abs(enemy.position.x - player.position.x) < 50 and enemy.state ~= 'attackranged_finish' or 'attackranged_start' then
        velocity = 70
      

    elseif math.abs(enemy.position.x - player.position.x) < 250 then
      enemy.idletime = enemy.idletime + dt
      
      if enemy.idletime >= 2 then
        enemy.state = 'attackranged_start'
        enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        enemy.props.attackranged(enemy)
        enemy.idletime = 0
      end

    else
      enemy.idletime = 0 
    end

      if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
        enemy.direction = 'left'
      elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
        enemy.direction = 'right'
      end

    if enemy.state ~= 'attackranged_start' or 'attackranged_finish' then
      enemy.velocity.x = 0
    else
    enemy.velocity.x = 70 * direction
    end

  end

}
