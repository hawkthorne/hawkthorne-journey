local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Projectile = require 'nodes/projectile'
local Gamestate = require 'vendor/gamestate'

return {
    name = 'cat',
    die_sound = 'meow',
    position_offset = { x = 0, y = 0 },
    height = 20,
    width = 40,
    bb_height = 20,
    bb_width = 32,
    bb_offset = {x=3, y=0},
    hp = 1,
    tokens = 1,
    hand_x = 0,
    hand_y = 6,
    jumpkill = true,
    damage = 0,
    chargeUpTime = 2,
    reviveDelay = 3,
    attackDelay = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.5 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            right = {'once', {'1,4'}, 0.25},
            left = {'once', {'2,4'}, 0.25},
        },
        default = {
            right = {'loop', {'1,2-3'}, 0.25},
            left = {'loop', {'2,2-3'}, 0.25},
        },
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.maxx = enemy.position.x + 200
        enemy.minx = enemy.position.x - 200
        enemy.velocity.x = enemy.direction=='left' and 20 or -20
    end,
    hurt = function( enemy )
        enemy.state = 'dying'
        if enemy.currently_held then
            enemy.currently_held:die()
        end
    end,
    update = function( dt, enemy, player, level )
        if enemy.position.x > enemy.maxx then 
            enemy.direction = 'left'
            enemy.velocity.x = 20
        elseif enemy.position.x < enemy.minx then 
            enemy.direction = 'right'
            enemy.velocity.x = -20
        end
    end,
}
