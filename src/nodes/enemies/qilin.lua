local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
    name = 'qilin',
    die_sound = 'manicorn_neigh',
    position_offset = { x = 0, y = 0 },
    height = 58,
    width = 72,
    hp = 15,
    damage = 3,
    jumpkill = false,
    tokens = 10,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        default = {
            left = {'loop', {'1-2,1'}, 0.2},
            right = {'loop', {'1-2,2'}, 0.2}
        },
        attack = {
            left = {'loop', {'3-5,1'}, 0.2},
            right = {'loop', {'3-5,2'}, 0.2}
        },
        attack_charge = {
            left = {'loop', {'1-2,1'}, 0.2},
            right = {'loop', {'1-2,2'}, 0.2}
        },
        hurt = {
            left = {'once', {'6,1'}, 0.4},
            right = {'once', {'6,2'}, 0.4}
        },
        dying = {
            left = {'once', {'7-8,1'}, 0.4},
            right = {'once', {'7-8,2'}, 0.4}
        }
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.maxx = enemy.position.x + 24
        enemy.minx = enemy.position.x - 24
    end,
    attack = function( enemy )
        enemy.state = 'attack'
        Timer.add(5, function() 
            if enemy.state ~= 'dying' and enemy.state ~= 'dyingattack' then
                enemy.state = 'default'
                enemy.maxx = enemy.position.x + 24
                enemy.minx = enemy.position.x - 24
                enemy.jumpkill = true
            end
        end)
    end,
    hurt = function( enemy )
        enemy.state = 'hurt'
    end,
    dying = function( enemy )
        enemy.state = 'dying'
    end,
    update = function( dt, enemy, player )
        if enemy.position.x > player.position.x then
            enemy.direction = 'left'
        else
            enemy.direction = 'right'
        end
    end
}