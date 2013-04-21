local sound = require 'vendor/TEsound'

return{
    name = 'humbug',
    die_sound = 'acorn_crush',
    position_offset = { x = 0, y = 0 },
    height = 40,
    width = 50,
    damage = 1,
    hp = 1,
    tokens = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    antigravity = true,
    animations = {
        dying = {
            right = {'once', {'1,1'}, 0.1},
            left = {'once',{'1,1'}, 0.1}
        },
        default = {
            right = {'loop', {'1-6, 1'}, 0.25},
            left = {'loop', {'1-6, 1'}, 0.25}
        },
    },
    enter = function(enemy)
        enemy.start_y = enemy.position.y
        enemy.end_y = enemy.start_y - (enemy.height*2)
    end,
    update = function( dt, enemy, player )
        if enemy.position.x > player.position.x then
            enemy.direction = 'left'
        else
            enemy.direction = 'right'
        end
        if enemy.state == 'default' then
            if enemy.position.y >= enemy.start_y then
                enemy.going_up = true
            end
            if enemy.position.y <= enemy.end_y then
                enemy.going_up = false
            end
            if enemy.going_up then
                enemy.position.y = enemy.position.y - 20*dt
            else
                enemy.position.y = enemy.position.y + 20*dt
            end
        end
    end
}