local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
    name = 'kungpaochicken',
    die_sound = 'cluck',
    position_offset = { x = 0, y = 0 },
    height = 48,
    width = 48,
    damage = 2,
    hp = 3,
    tokens = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            left = {'once', {'1,4'}, 0.25},
            right = {'once', {'2,4'}, 0.25}
        },
        default = {
            left = {'loop', {'1-5,2'}, 0.1},
            right = {'loop', {'1-5,3'}, 0.1}
        },
        hurt = {
            left = {'once', {'1,4'}, 0.25},
            right = {'once', {'2,4'}, 0.25}
        },
        enter = {
            left = {'once', {'4,2'}, 0.25},
            right = {'once', {'4,1'}, 0.25}
        },
        flying = {
            left = {'loop', {'1-2,1'}, 0.25},
            right = {'loop', {'3-4,1'}, 0.25}
        },
        attack = {
            left = {'loop', {'1-5,2'}, 0.25},
            right = {'loop', {'1-5,3'}, 0.25}
        },
        still = {
            left = {'loop', {'3,4'}, 0.25},
            right = {'loop', {'4,4'}, 0.25}
        }
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
    end,
    update = function( dt, enemy, player, level )
        if enemy.deadthen then return end
        
        local direction = player.position.x > enemy.position.x and -1 or 1

        if enemy.velocity.y > 1 then
            enemy.state = 'flying'
            enemy.jumpkill = false
            enemy.velocity.y = 15
        elseif math.abs(enemy.velocity.y) < 1 then
            enemy.state = 'default'
            enemy.jumpkill = true
            enemy.velocity.y = 0
            if enemy.state ~= 'still' then
                enemy.velocity.x = 80 * direction
            end
        end
     
        if enemy.position.x - player.position.x < 2 then
            enemy.direction = 'right'
        else
            enemy.direction = 'left'
        end
        if math.abs(enemy.position.x - player.position.x) < 2 then
            enemy.state = 'still'
            enemy.last_jump = enemy.last_jump + dt
            if enemy.last_jump > 0.5 then
                enemy.state = 'flying'
                enemy.jumpkill = false
                enemy.last_jump = math.random()
                enemy.velocity.y = -500
                enemy.drop = true
            end
        end
    end
}
