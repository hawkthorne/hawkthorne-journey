local sound = require 'vendor/TEsound'

return{
    name = 'humbug',
    die_sound = 'acorn_crush',
    position_offset = { x = 0, y = -1 },
    height = 40,
    width = 58,
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
            right = {'once', {'7,2'}, 0.4},
            left = {'once',{'7,1'}, 0.4}
        },
        default = {
            right = {'loop', {'1-6, 2'}, 0.1},
            left = {'loop', {'1-6, 1'}, 0.1}
        },
    },
    enter = function(enemy)
        enemy.start_y = enemy.position.y - enemy.height
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
                enemy.position.y = enemy.position.y - 30*dt
            else
                enemy.position.y = enemy.position.y + 30*dt
            end
        end
    end
}