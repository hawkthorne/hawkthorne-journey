local sound = require 'vendor/TEsound'

return { 
    name = 'rubberspider',
    die_sound = 'boing',
    height = 24,
    width = 24,
    antigravity = true,
    hp = 100000,
    vulnerabilities = {'blunt'},
    damage = 0,
    knockback = 0,
    dyingdelay = 0.1,
    peaceful = true,
    tokens = 3,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        default = {
            left = {'loop', {'1,1'}, 1},
            right ={'loop', {'1,1'}, 1}
        },
        hurt = {
            right = {'once', {'2,1','3,1','4,1','5,1'}, 1},
            left ={'once', {'2,2','3,2','4,2','5,2'}, 1}
        },
        dying = {
            right = {'once', {'2,1','3,1','4,1','5,1'}, 1},
            left ={'once', {'2,2','3,2','4,2','5,2'}, 1}
        }
    }
}