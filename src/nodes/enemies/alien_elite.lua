local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
  name = 'alien_elite',
  height = 48,
  width = 48,
  damage = 8,
  jumpkill = true,
  attack_bb = true,
  bb_width = 30,
  bb_height = 48,
  bb_offset = {x=8, y=0},
  attack_width = 15,
  --attack_height = 10,
  --attack_offset = { x = 14, y = 4},
  velocity = {x = 0, y = 0},
  hp = 10,
  vulnerabilities = {'slash'},
  jumpBounce = true,
  tokens = 5,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },

  animations = {
    dying = {
      right = {'once', {'1,2', '6-7,2'}, 0.1},
      left = {'once', {'1,1', '6-7,1'}, 0.1}
    },
    default = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
    hurt = {
      right = {'loop', {'1,2'}, 0.2},
      left = {'loop', {'1,1'}, 0.2}
    },
    attack = {
      right = {'loop', {'1-5,2'}, 0.2},
      left = {'loop', {'1-5,1'}, 0.2}
    },
  },

  enter = function( enemy )
    enemy.direction = math.random(2) == 1 and 'left' or 'right'
    enemy.state = 'attack'
    enemy.velocity.x = math.random(40,60)
  end,

  update = function( dt, enemy, player, level )
    if enemy.dead then return end
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end

    if player.position.x > (enemy.position.x - 30) and player.position.x < enemy.position.x then
    	local state = enemy.state 
    	enemy.state = 'attack'
    	enemy.collider:setSolid(enemy.attack_bb)
    	Timer.add(0.8, function() enemy.collider:setGhost(enemy.attack_bb) enemy.state = state end)
    elseif player.position.x > enemy.position.x and player.position.x < (enemy.position.x +78) then
    	local state = enemy.state 
    	enemy.state = 'attack'
    	enemy.collider:setSolid(enemy.attack_bb)
    	Timer.add(0.8, function() enemy.collider:setGhost(enemy.attack_bb) enemy.state = state end)
    end
    local direction = enemy.direction == 'left' and 1 or -1
    enemy.velocity.x = enemy.velocity.x *direction
  end
}