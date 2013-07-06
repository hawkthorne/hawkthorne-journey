local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
    name = 'guitarist',
    die_sound = 'trombone_temp',
    position_offset = { x = 0, y = 0 },
    height = 48,
    width = 48,
    damage = 4,
    bb_width = 30,
    hp = 16,
    tokens = 7,
    velocity = { x = 35, y = 0},
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            right = {'loop', {'5-8,2'}, 0.25},
            left = {'loop', {'1-4,2'}, 0.25}
        },
        default = {
            right = {'loop', {'5-8,2'}, 0.2},
            left = {'loop', {'1-4,2'}, 0.2}
        },
        hurt = {
            right = {'loop', {'5-8,2'}, 0.2},
            left = {'loop', {'1-4,2'}, 0.2}
        },
        dying = {
            right = {'loop', {'5-8,2'}, 0.2},
            left = {'loop', {'1-4,2'}, 0.2}
        },
        attack = {
            right = {'loop', {'6-7,3'}, 0.15},
            left = {'loop', {'3-4,3'}, 0.15}
        }
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.maxx = enemy.position.x + 48
        enemy.minx = enemy.position.x - 48
    end,
    update = function( dt, enemy, player, level )
        if enemy.dead then return end
     
        if enemy.position.x > enemy.maxx and enemy.state ~= 'attack' then
            enemy.direction = 'left'
        elseif enemy.position.x < enemy.minx and enemy.state ~= 'attack'then
            enemy.direction = 'right'
        end
        
        if (enemy.state == 'attack' or enemy.state == 'dying') and math.abs(enemy.position.x - player.position.x) > 5 then
            enemy.direction = enemy.position.x < player.position.x and 'right' or 'left'
        end
        
        local direction = enemy.direction == 'left' and 1 or -1
       
        enemy.velocity.x = 50 * direction

    end
    
}
