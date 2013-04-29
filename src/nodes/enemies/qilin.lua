local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
    name = 'qilin',
    die_sound = 'manicorn_neigh',
    position_offset = { x = 0, y = 0 },
    height = 58,
    width = 72,
    bb_height = 50,
    bb_width = 65,
    bb_offset = {x=0, y=9},
    hp = 15,
    damage = 3,
    jumpkill = true,
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
        enemy.state = 'default'
    end,
    attack = function( enemy )
        enemy.state = 'attack'
        enemy.jumpkill = false
    end,
    hurt = function( enemy )
        enemy.state = 'hurt'
    end,
    dying = function( enemy )
        enemy.state = 'dying'
    end,
    default = function( enemy)
        enemy.state = 'default'
        enemu.jumpkill = true
    end,
    update = function( dt, enemy, player )
        if enemy.state == 'default' then
            if enemy.position.x > player.position.x then
                enemy.direction = 'left'
            else
                enemy.direction = 'right'
            end
            enemy.jumkill = true
            Timer.add(2, function() 
                if enemy.state ~= 'dying' then
                    enemy.jumpkill = false
                    enemy.state = 'attack'
                end
            end)
        end
        if enemy.state == 'attack' then
            if math.abs(player.position.x - enemy.position.x) > 20 then
                if (enemy.direction == 'left' and enemy.position.x < player.position.x) or
                    (enemy.direction == 'right' and enemy.position.x > player.position.x) then
                    enemy.state = 'default'
                end
            end
            if enemy.direction == 'left' then
                enemy.position.x = enemy.position.x - 350 * dt
            else
                enemy.position.x = enemy.position.x + 350 * dt
            end
        end
    end
}