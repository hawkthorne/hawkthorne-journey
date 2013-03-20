local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
    name = 'trombone',
    position_offset = { x = 0, y = 0 },
    height = 39,
    width = 50,
    damage = 2,
    hp = 4,
    tokens = 4,
    velocity = { x = 50, y = 0},
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            right = {'loop', {'5-8,1'}, 0.25},
            left = {'loop', {'1-4,1'}, 0.25}
        },
        default = {
            right = {'loop', {'5-8,1', '7,1'}, 0.25},
            left = {'loop', {'1-4,1', '3,1'}, 0.25}
        },
        default = {
            right = {'loop', {'5-8,2'}, 0.5},
            left = {'loop', {'1-4,2'}, 0.5}
        }
    },
    update = function( dt, enemy, player, level )
        if enemy.dead then return end

        enemy.velocity.x = 50

    end
    
}