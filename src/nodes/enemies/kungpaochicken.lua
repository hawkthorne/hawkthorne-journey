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
            enemy.velocity.y = 10
        elseif math.abs(enemy.velocity.y) < 1 then
            enemy.state = 'default'
            enemy.velocity.y = 0
            enemy.velocity.x = 80 * direction
        end
     
        if enemy.position.x < player.position.x then
            enemy.direction = 'right'
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
            enemy.direction = 'left'
        end
    end
}
 